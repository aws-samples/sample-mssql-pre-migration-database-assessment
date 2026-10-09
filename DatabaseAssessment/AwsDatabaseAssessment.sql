/*
#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

*/
SET NOCOUNT ON

USE [master]
go
CREATE DATABASE [AwsDatabaseAssessment]
GO
USE [AwsDatabaseAssessment]
GO
/****** Object:  Schema [raw]    Script Date: 2/2/2023 6:01:49 PM ******/
CREATE SCHEMA [raw]
GO
CREATE SCHEMA [mpa]
go
/****** Object:  UserDefinedFunction [dbo].[ufn_RDSInstanceRecommendation]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[ufn_RDSInstanceRecommendation] (@Databases VARCHAR(512),@SQLInstance VARCHAR(50))
RETURNS VARCHAR(512)
AS
BEGIN
	declare @cpu_max_agg TABLE
(
		LogicalCpuCount INT,
		CpuUsage DECIMAL(8, 2)
);

	INSERT INTO @cpu_max_agg
		(
		LogicalCpuCount,
		CpuUsage
		)
	SELECT [LogicalCPUCount],
		SUM(ISNULL([CPUPercent], 0))
	FROM dbo.vw_database_general_information
	WHERE DatabaseName IN (SELECT value
		FROM STRING_SPLIT( @Databases, ','))
		AND SQLInstance = @SQLInstance
	GROUP BY [LogicalCPUCount];

	DECLARE @VcpusNeeded AS TABLE(vcpu_recommendation INT)


	INSERT INTO @VcpusNeeded
		(
		vcpu_recommendation
		)
	SELECT SUM(   CASE
                  WHEN CAST((ISNULL(CpuUsage, 0) / 100.) * LogicalCpuCount AS INT) < 1 THEN
                      1
                  WHEN CAST((ISNULL(CpuUsage, 0) / 100.) * LogicalCpuCount AS INT) >= 1
			AND CAST((CpuUsage / 100.) * LogicalCpuCount AS INT) <= 2 THEN
                      2
				  WHEN CAST((ISNULL(CpuUsage, 0) / 100.) * LogicalCpuCount AS INT) > 2
			AND CAST((CpuUsage / 100.) * LogicalCpuCount AS INT) <= 4 THEN
                      4
                  ELSE
                      CAST((ISNULL(CpuUsage, 0) / 100.) * LogicalCpuCount AS INT)
              END
          ) AS CPUAmountNeeded
	FROM @cpu_max_agg;



	IF (SELECT vcpu_recommendation
	FROM @VcpusNeeded) = 1
BEGIN
		UPDATE @VcpusNeeded SET vcpu_recommendation = 2
	END
	IF (SELECT vcpu_recommendation
	FROM @VcpusNeeded) = 3
BEGIN
		UPDATE @VcpusNeeded SET vcpu_recommendation = 4
	END
	IF (SELECT vcpu_recommendation
		FROM @VcpusNeeded) > 4 AND (SELECT vcpu_recommendation
		FROM @VcpusNeeded) <=8
BEGIN
		UPDATE @VcpusNeeded SET vcpu_recommendation = 8
	END
	IF (SELECT vcpu_recommendation
		FROM @VcpusNeeded) > 8 AND (SELECT vcpu_recommendation
		FROM @VcpusNeeded) <=12
BEGIN
		UPDATE @VcpusNeeded SET vcpu_recommendation = 8
	END
	IF (SELECT vcpu_recommendation
		FROM @VcpusNeeded) > 12 AND (SELECT vcpu_recommendation
		FROM @VcpusNeeded) <=25
BEGIN
		UPDATE @VcpusNeeded SET vcpu_recommendation = 16
	END
	IF (SELECT vcpu_recommendation
	FROM @VcpusNeeded) > 25
BEGIN
		UPDATE @VcpusNeeded SET vcpu_recommendation = 32
	END
	DECLARE @RDSRecomendationsResult VARCHAR(200) = (SELECT DISTINCT rds.instance_type, rds.vcpu, rds.memory
	FROM @VcpusNeeded AS v1
		JOIN dbo.rds_instance_sizes AS rds
		ON rds.vcpu = v1.vcpu_recommendation
	FOR JSON PATH)

	RETURN (@RDSRecomendationsResult)
END
GO
/****** Object:  Table [raw].[server_audit_information]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [raw].[server_audit_information]
(
	[SQLInstance] [varchar](50) NULL,
	[audit_id] [nvarchar](100) NULL,
	[audit_name] [nvarchar](250) NULL,
	[server_specification_name] [nvarchar](100) NULL,
	[audit_action_name] [nvarchar](150) NULL,
	[is_state_enabled] [bit] NULL,
	[is_group] [bit] NULL,
	[audit_action_id] [nvarchar](150) NULL,
	[create_date] [datetime] NULL,
	[modify_date] [datetime] NULL,
	[collect_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_server_audit_information_sql_instance_database_name_table_name] ON [raw].[server_audit_information]
(
	[SQLInstance] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Object:  Table [raw].[database_db_audit_information]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [raw].[database_db_audit_information]
(
	[SQLInstance] [varchar](50) NULL,
	[audit_id] [nvarchar](100) NULL,
	[audit_name] [nvarchar](250) NULL,
	[database_specification_name] [nvarchar](150) NULL,
	[audit_action_name] [nvarchar](150) NULL,
	[is_state_enabled] bit NULL,
	[is_group] bit NULL,
	[create_date] [datetime] NULL,
	[audited_result] [nvarchar](50) NULL,
	[DatabaseName] [varchar](100) NULL,
	[collect_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_database_db_audit_information_sql_instance_database_name] ON [raw].[database_db_audit_information]
(
	[SQLInstance] ASC,
	[DatabaseName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Object:  View [dbo].[vw_database_audit_information]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_database_audit_information]
AS
	SELECT srv_audit.SQLInstance,
		srv_audit.audit_name AS ServerAuditName,
		srv_audit.is_state_enabled AS ServerAuditEnabled,
		db_audit.DatabaseName,
		db_audit.audit_name AS DatabaseAuditName,
		db_audit.database_specification_name,
		db_audit.audit_action_name,
		db_audit.is_state_enabled AS DatabaseAuditEnabled
	FROM raw.server_audit_information AS srv_audit
		LEFT JOIN raw.database_db_audit_information AS db_audit
		ON db_audit.SQLInstance = srv_audit.SQLInstance;
GO
/****** Object:  Table [raw].[ssis_packages_connection_type_msdb]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [raw].[ssis_packages_connection_type_msdb]
(
	[SQLInstance] [varchar](50) NULL,
	[FolderName] [varchar](100) NULL,
	[PackageName] [varchar](128) NULL,
	[ConnectionType] [varchar](256) NULL,
	[TaskType] [varchar](256) NULL,
	[collect_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_ssis_packages_connection_type_msdb_sql_instance] ON [raw].[ssis_packages_connection_type_msdb]
(
	[SQLInstance] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

GO
CREATE TABLE [raw].[database_filestream_information]
(
	[SQLInstance] [nvarchar](50) NULL,
	[DatabaseName] [nvarchar](100) NULL,
	[non_transacted_access] smallint NULL,
	[non_transacted_access_desc] [varchar](15) NULL,
	[directory_name] [nvarchar](512) NULL,
	[collect_date] datetime NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_database_filestream_information_sql_instance] ON [raw].[database_filestream_information]
(
	[SQLInstance] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [raw].[database_msdb_ssis_packages]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [raw].[database_msdb_ssis_packages]
(
	[SQLInstance] [varchar](50) NULL,
	[RootFolder] [nvarchar](100) NULL,
	[FullPath] [nvarchar](500) NULL,
	[PackageName] [nvarchar](100) NULL,
	[Description] [nvarchar](512) NULL,
	[collect_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_database_msdb_ssis_packages_sql_instance] ON [raw].[database_msdb_ssis_packages]
(
	[SQLInstance] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [raw].[ssis_packages_connection_type_ssisdb]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [raw].[ssis_packages_connection_type_ssisdb]
(
	[SQLInstance] [varchar](50) NULL,
	[ProjectName] [varchar](100) NULL,
	[PackageName] [varchar](128) NULL,
	[ConnectionType] [varchar](256) NULL,
	[collect_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_ssis_packages_connection_type_ssisdb_sql_instance] ON [raw].[ssis_packages_connection_type_ssisdb]
(
	[SQLInstance] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [raw].[ssis_packages_component_type_ssisdb]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [raw].[ssis_packages_component_type_ssisdb]
(
	[SQLInstance] [varchar](50) NULL,
	[ProjectName] [varchar](100) NULL,
	[PackageName] [varchar](128) NULL,
	[ComponentType] [varchar](256) NULL,
	[collect_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_ssis_packages_component_type_ssisdb_sql_instance] ON [raw].[ssis_packages_component_type_ssisdb]
(
	[SQLInstance] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [raw].[database_ssisdb_ssis_packages]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [raw].[database_ssisdb_ssis_packages]
(
	[SQLInstance] [varchar](50) NULL,
	[FolderName] [varchar](128) NULL,
	[ProjectName] [varchar](128) NULL,
	[PackageName] [varchar](128) NULL,
	[Description] [varchar](256) NULL,
	[DeployedBy] [varchar](50) NULL,
	[LastDeploymentTime] [datetime] NULL,
	[CreatedTime] [varchar](50) NULL,
	[collect_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_database_ssisdb_ssis_packages_sql_instance] ON [raw].[database_ssisdb_ssis_packages]
(
	[SQLInstance] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vw_ssis_package_information]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_ssis_package_information]
AS
			SELECT DISTINCT msdb.SQLInstance,
			[RootFolder],
			[FullPath],
			[PackageName],
			Description, (SELECT ConnectionType, TaskType
			FROM [raw].[ssis_packages_connection_type_msdb] as connectors
			WHERE msdb.[PackageName] = connectors.[PackageName]
				AND msdb.SQLInstance = connectors.SQLInstance
			FOR JSON PATH) as RDSNonSupportedComponents,
			'Deployed in MSDB' AS 'Package Deployment Type'
		FROM raw.database_msdb_ssis_packages AS msdb
	UNION ALL
		SELECT ssisdb.SQLInstance,
			FolderName,
			CONCAT(FolderName,'/',[ProjectName]) AS [Full Path],
			[PackageName],
			Description, (SELECT connectors.ConnectionType, components.ComponentType
			FROM [raw].[ssis_packages_component_type_ssisdb] as components
				LEFT JOIN raw.ssis_packages_connection_type_ssisdb as connectors
				ON components.SQLInstance = connectors.SQLInstance
					AND components.ProjectName = connectors.ProjectName
					AND components.PackageName = connectors.PackageName
			WHERE ssisdb.[PackageName] = components.[PackageName]
				AND ssisdb.SQLInstance = components.SQLInstance
			FOR JSON PATH) as RDSNonSupportedComponents,
			'Deployed in SSISDB' AS 'Package Deployment Type'
		FROM raw.database_ssisdb_ssis_packages AS ssisdb;
GO
/****** Object:  Table [raw].[server_agent_jobs_information]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [raw].[server_agent_jobs_information]
(
	[SQLInstance] [varchar](50) NULL,
	[JobName] [nvarchar](128) NULL,
	[enabled] tinyint NULL,
	[description] [nvarchar](512) NULL,
	[JobOwner] [nvarchar](50) NULL,
	[JobCategoryName] [nvarchar](50) NULL,
	[step_id] int NULL,
	[step_name] [nvarchar](128) NULL,
	[subsystem] [nvarchar](50) NULL,
	[database_name] [nvarchar](100) NULL,
	[command] [nvarchar](MAX) NULL,
	[On_Success] [nvarchar](20) NULL,
	[On_Failure] [nvarchar](20) NULL,
	[notify_level_eventlog] int NULL,
	[notify_level_email] int NULL,
	[notify_email_operator_id] int NULL,
	[delete_level] int NULL,
	[collect_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_server_agent_jobs_information_sql_instance] ON [raw].[server_agent_jobs_information]
(
	[SQLInstance] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [raw].[database_general_information]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [raw].[database_general_information]
(
	[SQLInstance] [varchar](50) NULL,
	[DatabaseID] int NULL,
	[DatabaseName] [varchar](100) NULL,
	[CompatibilityLevel] int NULL,
	[Owner] [nvarchar](50) NULL,
	[CollationName] [nvarchar](50) NULL,
	[UserAccess] [nvarchar](20) NULL,
	[ReadOnlyDatabase] bit NULL,
	[DatabaseState] [nvarchar](15) NULL,
	[RecoveryModel] [nvarchar](15) NULL,
	[ReadCommittedSnapshotIsolation] bit NULL,
	[SnapshotIsolationState] [varchar](3) NULL,
	[IsDistributorDatabase] bit NULL,
	[IsSubscriberDatabase] bit NULL,
	[IsPublishedDatabase] bit NULL,
	[StretchDatabaseEnabled] bit NULL,
	[last_user_seek] datetime NULL,
	[last_user_scan] datetime NULL,
	[last_user_lookup] datetime NULL,
	[last_user_update] datetime NULL,
	[collect_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_general_database_information_database_name] ON [raw].[database_general_information]
(
	[SQLInstance] ASC,
	[DatabaseName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vw_database_agent_job_information]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_database_agent_job_information]
AS
	SELECT gen_db.SQLInstance AS SQLInstance,
		gen_db.[DatabaseName],
		srv_jobs.JobName,
		srv_jobs.step_id AS JobStepId,
		srv_jobs.step_name AS JobStepName,
		srv_jobs.subsystem AS StepSubsystem,
		srv_jobs.ENABLED AS JobEnabled,
		(SELECT DISTINCT subsystem
		FROM raw.server_agent_jobs_information as job_step
		WHERE job_step.SQLInstance = srv_jobs.SQLInstance
			AND job_step.JobName = srv_jobs.JobName
		FOR JSON PATH) as subsystems_used
	FROM raw.database_general_information AS gen_db
		LEFT JOIN raw.server_agent_jobs_information AS srv_jobs
		ON gen_db.SQLInstance = srv_jobs.SQLInstance
			AND gen_db.[DatabaseName] = srv_jobs.database_name
	WHERE srv_jobs.JobName IS NOT NULL
GO
/****** Object:  Table [raw].[database_user_permissions]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [raw].[database_user_permissions]
(
	[SQLInstance] [varchar](50) NULL,
	[DatabaseName] [varchar](100) NULL,
	[DatabaseUser] [varchar](100) NULL,
	[UserType] [nvarchar](15) NULL,
	[CreateDate] [datetime] NULL,
	[Roles] [nvarchar](2500) NULL,
	[collect_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_database_user_permissions_sql_instance] ON [raw].[database_user_permissions]
(
	[SQLInstance] ASC,
	[DatabaseName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [raw].[server_logins_and_permissions]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [raw].[server_logins_and_permissions]
(
	[SQLInstance] [varchar](50) NULL,
	[LoginName] [nvarchar](250) NULL,
	[Roles] [nvarchar](2500) NULL,
	[collect_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_server_logins_and_permissions_sql_instance_login_name] ON [raw].[server_logins_and_permissions]
(
	[SQLInstance] ASC,
	[LoginName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Object:  Table [raw].[server_proxy_agent_information]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [raw].[server_proxy_agent_information]
(
	[SQLInstance] [varchar](50) NULL,
	[ProxyID] int NULL,
	[ProxyName] [nvarchar](50) NULL,
	[CredentialID] [nvarchar](20) NULL,
	[CredentialIdentity] [nvarchar](100) NULL,
	[JobStepID] int NULL,
	[StepName] [nvarchar](128) NULL,
	[JobName] [nvarchar](128) NULL,
	[collect_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_server_proxy_agent_information_sql_instance] ON [raw].[server_proxy_agent_information]
(
	[SQLInstance] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vw_database_agent_job_information_all]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vw_database_agent_job_information_all]
AS
	SELECT DISTINCT gen_db.SQLInstance AS SQLInstance,
		gen_db.[DatabaseName],
		srv_jobs.JobName,
		srv_jobs.ENABLED AS JobEnabled,
		(SELECT DISTINCT subsystem
		FROM raw.server_agent_jobs_information as job_step
		WHERE job_step.SQLInstance = srv_jobs.SQLInstance
			AND job_step.JobName = srv_jobs.JobName
		FOR JSON PATH) as subsystems_used,
		proxy.[ProxyName], proxy.[CredentialIdentity]
	FROM raw.database_general_information AS gen_db
		LEFT JOIN raw.server_agent_jobs_information AS srv_jobs
		ON gen_db.SQLInstance = srv_jobs.SQLInstance
			AND gen_db.[DatabaseName] = ISNULL(srv_jobs.database_name,'master')
		LEFT JOIN raw.server_proxy_agent_information as proxy
		ON srv_jobs.SQLInstance = proxy.SQLInstance
			AND srv_jobs.JobName = proxy.[JobName]
	WHERE srv_jobs.JobName IS NOT NULL
GO
/****** Object:  Table [raw].[server_installed_services_information]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [raw].[server_installed_services_information]
(
	[SQLInstance] [varchar](50) NULL,
	[PhysicalServerName] [varchar](50) NULL,
	[SQLInstanceName] [varchar](50) NULL,
	[SQLServerServices] [varchar](256) NULL,
	[CurrentServiceServiceStatus] [nvarchar](50) NULL,
	[collect_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_server_installed_services_information_sql_instance] ON [raw].[server_installed_services_information]
(
	[SQLInstance] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [raw].[server_timezone_information]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [raw].[server_timezone_information]
(
	[SQLInstance] [varchar](50) NULL,
	[TimezoneConfiguration] [nvarchar](50) NULL,
	[collect_date] datetime NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_server_timezone_information_sql_instance] ON [raw].[server_timezone_information]
(
	[SQLInstance] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [raw].[database_cpu_utilization]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [raw].[database_cpu_utilization]
(
	[SQLInstance] [varchar](50) NULL,
	[CPURank] [nvarchar](5) NULL,
	[DatabaseName] [varchar](100) NULL,
	[CPUTimeMiliSecond] [nvarchar](50) NULL,
	[CPUPercent] [decimal](8, 2) NULL,
	[collect_date] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [ix_cpu_utilization_per_db_sql_instance_database_name]    Script Date: 12/7/2022 11:45:31 AM ******/
CREATE CLUSTERED INDEX [ix_cpu_utilization_per_db_sql_instance_database_name] ON [raw].[database_cpu_utilization]
(
	[SQLInstance] ASC,
	[DatabaseName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [raw].[database_size_information]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [raw].[database_size_information]
(
	[SQLInstance] [varchar](50) NULL,
	[DatabaseName] [varchar](100) NULL,
	[FileName] [nvarchar](512) NULL,
	[PhysicalName] [nvarchar](512) NULL,
	[FileType] [nvarchar](50) NULL,
	[FilegroupType] [nvarchar](50) NULL,
	[TotalSizeinMB] [decimal](10, 2) NULL,
	[AvailableSpaceInMB] [decimal](10, 2) NULL,
	[UsedSpaceinMB] [decimal](10, 2) NULL,
	[collect_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_database_size_information_sqlinstance_database_name] ON [raw].[database_size_information]
(
	[SQLInstance] ASC,
	[DatabaseName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Object:  Table [raw].[server_hardware_information]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [raw].[server_hardware_information]
(
	[SQLInstance] [varchar](50) NULL,
	[LogicalCPUCount] [smallint] NULL,
	[SchedulerCount] [smallint] NULL,
	[HyperthreadRatio] [smallint] NULL,
	[PhysicalCPUCount] [smallint] NULL,
	[PhysicalMemoryMB] [decimal](10, 2) NULL,
	[CommittedMemoryMB] [decimal](10, 2) NULL,
	[CommittedTargetMemoryMB] [decimal](10, 2) NULL,
	[MaxWorkersCount] [smallint] NULL,
	[AffinityType] [nvarchar](50) NULL,
	[SQLServerStartTime] datetime NULL,
	[SQLServerUpTimeHrs] int NULL,
	[VirtualMachineType] [nvarchar](50) NULL,
	[collect_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_hardware_information_sql_instance] ON [raw].[server_hardware_information]
(
	[SQLInstance] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [raw].[database_io_utilization]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [raw].[database_io_utilization]
(
	[SQLInstance] [varchar](50) NULL,
	[IORank] int NULL,
	[DatabaseName] [varchar](100) NULL,
	[TotalIOMB] [decimal](12,2) NULL,
	[TotalIOPercent] [decimal](12,2) NULL,
	[ReadIOMB] [decimal](12,2) NULL,
	[ReadIOPercent] [decimal](8,2) NULL,
	[WriteIOMB] [decimal](12,2) NULL,
	[WriteIOPercent] [decimal](8,2) NULL,
	[collect_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_database_io_utilization_sql_instance] ON [raw].[database_io_utilization]
(
	[SQLInstance] ASC,
	[DatabaseName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [raw].[server_general_information]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [raw].[server_general_information]
(
	[SQLInstance] [varchar](50) NULL,
	[InstallDate] datetime NULL,
	[SQLServerStartTime] datetime NULL,
	[SQLServerEdition] [nvarchar](50) NULL,
	[ProductLevel] [nvarchar](50) NULL,
	[ProductUpdateLevel] [nvarchar](50) NULL,
	[Collation] [nvarchar](50) NULL,
	[ProductBuildLevel] [nvarchar](50) NULL,
	[SQLServerMajorVersion] [nvarchar](50) NULL,
	[IsClustered] [varchar](5) NULL,
	[IsHadrEnabled] [varchar](5) NULL,
	[IsPolyBaseInstalled] [varchar](5) NULL,
	[OSVersion] [varchar](100) NULL,
	[collect_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_server_general_information_sql_instance] ON [raw].[server_general_information]
(
	[SQLInstance] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vw_database_general_information]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_database_general_information]
AS
	SELECT gen_db.SQLInstance AS SQLInstance,
		ISNULL(hwd.[LogicalCPUCount],0) AS [Logical CPU Count],
		ISNULL(hwd.[CommittedMemoryMB], 0) AS [Committed Memory (MB)],
		ISNULL(hwd.[CommittedTargetMemoryMB],0) AS [Committed Target Memory (MB)],
		gen_db.[DatabaseName],
		SUM(CAST(db_size.[TotalSizeinMB] AS DECIMAL(10, 2))) AS TotalSizeMB,
		SUM(CAST(db_size.[AvailableSpaceInMB] AS DECIMAL(10, 2))) AS AvailableSizeMB,
		SUM(CAST(db_size.[UsedSpaceinMB] AS DECIMAL(10, 2))) AS UsedSizeMB,
		gen_db.[CollationName] AS DatabaseCollation,
		gen_db.[ReadOnlyDatabase],
		gen_db.[RecoveryModel],
		gen_db.[IsDistributorDatabase],
		gen_db.[IsSubscriberDatabase],
		gen_db.[IsPublishedDatabase],
		gen_inst_info.[SQLServerEdition],
		gen_inst_info.[SQLServerMajorVersion],
		gen_inst_info.[ProductBuildLevel],
		gen_inst_info.Collation AS InstanceCollation,
		hwd.LogicalCpuCount,
		cpu_db.[CPURank],
		cpu_db.[CPUPercent],
		iops_db.[IORank],
		iops_db.[ReadIOPercent] AS ReadIOPercentage,
		iops_db.[WriteIOPercent] AS WriteIOPercentage,
		CASE
           WHEN ssrs_service.[SQLServerServices] IS NOT NULL THEN
               1
           ELSE
               0
       END AS SSRSDeployed,
		CASE
           WHEN ssas_service.[SQLServerServices] IS NOT NULL THEN
               1
           ELSE
               0
       END AS SSASDeployed,
		CASE
           WHEN ssis_service.[SQLServerServices] IS NOT NULL THEN
               1
           ELSE
               0
       END AS SSISDeployed,
		gen_inst_info.IsClustered,
		gen_inst_info.IsHadrEnabled,
		timezone.TimezoneConfiguration
	FROM raw.database_general_information AS gen_db
		JOIN raw.database_size_information db_size
		ON gen_db.[DatabaseName] = db_size.[DatabaseName]
			AND gen_db.SQLInstance = db_size.SQLInstance
		LEFT JOIN raw.server_general_information AS gen_inst_info
		ON gen_db.SQLInstance = gen_inst_info.SQLInstance
		LEFT JOIN raw.database_cpu_utilization AS cpu_db
		ON gen_db.[DatabaseName] = cpu_db.[DatabaseName]
			AND gen_db.SQLInstance = cpu_db.SQLInstance
		LEFT JOIN raw.server_hardware_information AS hwd
		ON gen_db.SQLInstance = hwd.SQLInstance
		LEFT JOIN raw.server_installed_services_information AS ssrs_service
		ON ssrs_service.SQLInstance = gen_db.SQLInstance
			AND ssrs_service.[SQLServerServices] = 'Reporting Service'
		LEFT JOIN raw.server_installed_services_information AS ssas_service
		ON ssas_service.SQLInstance = gen_db.SQLInstance
			AND ssas_service.[SQLServerServices] = 'Analysis Services'
		LEFT JOIN raw.server_installed_services_information AS ssis_service
		ON ssis_service.SQLInstance = gen_db.SQLInstance
			AND ssis_service.[SQLServerServices] = 'Intergration Service - Instance Independent'
		LEFT JOIN raw.server_timezone_information AS timezone
		ON gen_db.SQLInstance = timezone.SQLInstance
		LEFT JOIN raw.database_io_utilization AS iops_db
		ON gen_db.SQLInstance = iops_db.SQLInstance
			AND gen_db.[DatabaseName] = iops_db.[DatabaseName]
	WHERE gen_db.[DatabaseName] NOT IN ( 'master', 'model', 'msdb' )
	GROUP BY gen_db.SQLInstance,
         ISNULL(hwd.[LogicalCPUCount], 0),
         ISNULL(hwd.[CommittedMemoryMB], 0),
         ISNULL(hwd.[CommittedTargetMemoryMB], 0),
         CASE
         WHEN ssrs_service.[SQLServerServices] IS NOT NULL THEN
         1
         ELSE
         0
         END,
         CASE
         WHEN ssas_service.[SQLServerServices] IS NOT NULL THEN
         1
         ELSE
         0
         END,
         CASE
         WHEN ssis_service.[SQLServerServices] IS NOT NULL THEN
         1
         ELSE
         0
         END,
         gen_db.[DatabaseName],
         gen_db.[CollationName],
         gen_db.[ReadOnlyDatabase],
         gen_db.[RecoveryModel],
         gen_db.[IsDistributorDatabase],
         gen_db.[IsSubscriberDatabase],
         gen_db.[IsPublishedDatabase],
         gen_inst_info.[SQLServerEdition],
         gen_inst_info.[SQLServerMajorVersion],
         gen_inst_info.[ProductBuildLevel],
         gen_inst_info.Collation,
		 hwd.LogicalCpuCount,
         cpu_db.[CPURank],
         cpu_db.[CPUPercent],
         iops_db.[IORank],
         iops_db.[ReadIOPercent],
         iops_db.[WriteIOPercent],
         timezone.TimezoneConfiguration,
		 gen_inst_info.IsClustered,
	     gen_inst_info.IsHadrEnabled
GO
/****** Object:  Table [raw].[database_clr_information]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [raw].[database_clr_information]
(
	[SQLInstance] [varchar](50) NULL,
	[DatabaseName] [varchar](100) NULL,
	[SchemaName] [varchar](50) NULL,
	[ObjectName] [nvarchar](100) NULL,
	[AssemblyName] [nvarchar](100) NULL,
	[AssemblyClass] [nvarchar](1024) NULL,
	[AssemblyMethod] [nvarchar](100) NULL,
	[PermissionSetDesc] [nvarchar](50) NULL,
	[TypeDesc] [nvarchar](50) NULL,
	[collect_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_database_clr_information_sql_instance] ON [raw].[database_clr_information]
(
	[SQLInstance] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vw_clr_usage]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_clr_usage]
AS
	/*
-- =============================================
-- Author:      Marcos Freccia
-- Create date: 24.11.2021
-- Description: This procedure is only used for generating the ADM Questionnaire Spreadsheet - Confirm CLR Usage
-- =============================================
*/
	SELECT gen_db.SQLInstance,
		gen_db.DatabaseName,
		clr.ObjectName,
		clr.PermissionSetDesc,
		clr.TypeDesc
	FROM dbo.vw_database_general_information as gen_db
		LEFT JOIN raw.database_clr_information as clr
		ON gen_db.SQLInstance = clr.SQLInstance
			AND gen_db.DatabaseName = clr.DatabaseName
			AND clr.ObjectName IS NOT NULL
GO
/****** Object:  Table [dbo].[default_sp_configure]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[default_sp_configure]
(
	[ConfigurationName] [varchar](100) NULL,
	[State] [varchar](100) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[logins_exclusion_list]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[logins_exclusion_list]
(
	[id] [int] IDENTITY(1,1) NOT NULL,
	[login_name] [varchar](50) NULL,
	[reason] [varchar](100) NULL,
	[date_added] [datetime] NULL
)ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_logins_exclusion_list] ON [dbo].[logins_exclusion_list]
(
	[login_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[question_table]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[question_table]
(
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Question] [varchar](500) NULL,
	[Answer] [varchar](100) NULL,
	[Comments] [varchar](1000) NULL,
	[Environment] [varchar](30) NULL,
	[enabled] [bit] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_question_table] ON [dbo].[question_table]
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[rds_instance_sizes]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[rds_instance_sizes]
(
	[id] [int] IDENTITY(1,1) NOT NULL,
	[instance_type] [varchar](20) NULL,
	[vcpu] [int] NULL,
	[memory] [int] NULL,
	[network_performance] [varchar](20) NULL
)ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_rds_instance_sizes] ON [dbo].[rds_instance_sizes]
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [raw].[database_direct_reference_information]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [raw].[database_direct_reference_information]
(
	[SQLInstance] [varchar](50) NULL,
	[referencing_database_name] [varchar](100) NULL,
	[referencing_schema_name] [varchar](50) NULL,
	[referencing_object_name] [varchar](128) NULL,
	[referencing_object_type] [varchar](60) NULL,
	[referenced_database_location] [varchar](10) NULL,
	[referenced_server_name] [varchar](50) NULL,
	[referenced_database_name] [varchar](128) NULL,
	[referenced_schema_name] [varchar](128) NULL,
	[referenced_object_name] [varchar](128) NULL,
	[collect_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_database_direct_reference_information_sql_instance] ON [raw].[database_direct_reference_information]
(
	[SQLInstance] ASC,
	[referencing_database_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [raw].[database_downgrade_to_standard]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [raw].[database_downgrade_to_standard]
(
	[SQLInstance] [varchar](50) NULL,
	[DatabaseName] [varchar](100) NULL,
	[FeatureName] [varchar](256) NULL,
	[date_collect] [datetime] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_database_downgrade_to_standard_sql_instance] ON [raw].[database_downgrade_to_standard]
(
	[SQLInstance] ASC,
	[DatabaseName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [raw].[database_environment_settings_on_ssisdb]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [raw].[database_environment_settings_on_ssisdb]
(
	[SQLInstance] [varchar](50) NULL,
	[FolderName] [nvarchar](100) NULL,
	[EnvironmentName] [nvarchar](50) NULL,
	[VariableName] [nvarchar](100) NULL,
	[DataType] [nvarchar](100) NULL,
	[Value] [nvarchar](1024) NULL,
	[CreatedByName] varchar(100) NULL,
	[collect_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_database_environment_settings_on_ssisdb_sql_instance] ON [raw].[database_environment_settings_on_ssisdb]
(
	[SQLInstance] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [raw].[database_inmemory_information]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [raw].[database_inmemory_information]
(
	[SQLInstance] [varchar](50) NULL,
	[DatabaseName] [varchar](256) NULL,
	[SchemaName] varchar(50) NULL,
	[TableName] [varchar](256) NULL,
	[durability_desc] [nvarchar](60) NULL,
	[create_date] [datetime] NOT NULL,
	[modify_date] [datetime] NOT NULL,
	[collect_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_database_inmemory_information_sql_instance_database_name] ON [raw].[database_inmemory_information]
(
	[SQLInstance] ASC,
	[DatabaseName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [raw].[database_primary_key_information]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [raw].[database_primary_key_information]
(
	[SQLInstance] [varchar](50) NULL,
	[DatabaseName] [varchar](100) NULL,
	[SchemaName] [nvarchar](20) NULL,
	[TableName] [nvarchar](150) NULL,
	[collect_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_database_primary_key_information_sql_instance_database_name_table_name] ON [raw].[database_primary_key_information]
(
	[SQLInstance] ASC,
	[DatabaseName] ASC,
	[TableName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [raw].[database_replication_publisher_information]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [raw].[database_replication_publisher_information]
(
	[SQLInstance] [varchar](50) NULL,
	[PublisherDatabase] [nvarchar](100) NULL,
	[PublicationName] [nvarchar](128) NULL,
	[SchemaName] varchar(50) NULL,
	[TableName] [nvarchar](150) NULL,
	[SubscriberServerName] [nvarchar](50) NULL,
	[collect_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_database_replication_publisher_information_sql_instance] ON [raw].[database_replication_publisher_information]
(
	[SQLInstance] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [raw].[database_service_broker_information]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [raw].[database_service_broker_information]
(
	[SQLInstance] [varchar](50) NULL,
	[name] [nvarchar](128) NULL,
	[type] [nvarchar](128) NULL,
	[create_date] datetime NULL,
	[modify_date] datetime NULL,
	[collect_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_database_service_broker_information_sql_instance] ON [raw].[database_service_broker_information]
(
	[SQLInstance] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [raw].[database_ssrs_reports_information]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [raw].[database_ssrs_reports_information]
(
	[SQLInstance] [varchar](50) NULL,
	[ItemID] [nvarchar](50) NULL,
	[Path] [nvarchar](128) NULL,
	[Name] [nvarchar](100) NULL,
	[ParentID] [nvarchar](128) NULL,
	[TypeName] [nvarchar](50) NULL,
	[LinkSourceID] [nvarchar](100) NULL,
	[Description] [nvarchar](256) NULL,
	[Hidden] bit NULL,
	[CreatedBy] [nvarchar](50) NULL,
	[CreationDate] datetime NULL,
	[ModifiedBy] [nvarchar](50) NULL,
	[ModifiedDate] datetime NULL,
	[collect_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_database_ssrs_reports_information_sql_instance] ON [raw].[database_ssrs_reports_information]
(
	[SQLInstance] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [raw].[database_ssrs_reports_information]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [raw].[database_ssrs_subscription_information]
(
	[SQLInstance] [varchar](50) NULL,
	[SubscriptionOwner] NVARCHAR(255),
	[ModifiedDate] DATETIME,
	[Description] NVARCHAR(MAX),
	[EventType] NVARCHAR(255),
	[DeliveryExtension] NVARCHAR(255),
	[LastStatus] NVARCHAR(255),
	[LastRunTime] DATETIME,
	[NextRunTime] DATETIME,
	[ScheduleName] NVARCHAR(255),
	[ReportPath] NVARCHAR(MAX),
	[ReportDescription] NVARCHAR(MAX),
	[Parameters] NVARCHAR(MAX),
	[collect_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_database_ssrs_subscriptions_information_sql_instance] ON [raw].[database_ssrs_subscription_information]
(
	[SQLInstance] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Object:  Table [raw].[database_table_information]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [raw].[database_table_information]
(
	[SQLInstance] [nvarchar](50) NULL,
	[DatabaseName] [nvarchar](100) NULL,
	[SchemaName] [nvarchar](20) NULL,
	[TableName] [nvarchar](150) NULL,
	[collect_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_database_table_information_sql_instance] ON [raw].[database_table_information]
(
	[SQLInstance] ASC,
	[DatabaseName] ASC,
	[TableName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [raw].[database_user_securables]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [raw].[database_user_securables]
(
	[SQLInstance] [varchar](50) NULL,
	[UserName] [varchar](100) NULL,
	[type_desc] [varchar](50) NULL,
	[securables] [nvarchar](2500) NULL,
	[collect_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_database_user_securables_sql_instance] ON [raw].[database_user_securables]
(
	[SQLInstance] ASC,
	[UserName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [raw].[server_ag_information]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [raw].[server_ag_information]
(
	[SQLInstance] [varchar](50) NULL,
	[replica_server_name] [nvarchar](50) NULL,
	[Listener] [nvarchar](100) NULL,
	[Listener_port] int NULL,
	[Listener_state] [nvarchar](10) NULL,
	[database_name] [nvarchar](100) NULL,
	[ag_name] [nvarchar](100) NULL,
	[automated_backup_preference_desc] [nvarchar](20) NULL,
	[role_desc] [nvarchar](20) NULL,
	[synchronization_state_desc] [nvarchar](20) NULL,
	[availability_mode_desc] [nvarchar](20) NULL,
	[failover_mode_desc] [nvarchar](20) NULL,
	[primary_role_allow_connections_desc] [nvarchar](10) NULL,
	[secondary_role_allow_connections_desc] [nvarchar](10) NULL,
	[is_commit_participant] bit NULL,
	[synchronization_health_desc] [nvarchar](10) NULL,
	[last_commit_time] datetime NULL,
	[collect_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_server_ag_information_sql_instance] ON [raw].[server_ag_information]
(
	[SQLInstance] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [raw].[server_agent_alerts]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [raw].[server_agent_alerts]
(
	[SQLInstance] [varchar](50) NULL,
	[AlertName] [nvarchar](128) NULL,
	[EventSource] [nvarchar](50) NULL,
	[MessageID] int NULL,
	[severity] smallint NULL,
	[Enabled] int NULL,
	[has_notification] int NULL,
	[delay_between_responses] int NULL,
	[occurrence_count] int NULL,
	[last_occurrence_date] int NULL,
	[last_occurrence_time] int NULL,
	[collect_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_server_agent_alerts_sql_instance] ON [raw].[server_agent_alerts]
(
	[SQLInstance] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [raw].[server_agent_operators]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [raw].[server_agent_operators]
(
	[SQLInstance] [varchar](50) NULL,
	[name] [nvarchar](128) NULL,
	[enabled] int NULL,
	[email_address] [nvarchar](128) NULL,
	[last_email_date] int NULL,
	[last_email_time] int NULL,
	[collect_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_server_agent_operators_sql_instance] ON [raw].[server_agent_operators]
(
	[SQLInstance] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [raw].[server_backup_information]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [raw].[server_backup_information]
(
	[SQLInstance] [varchar](50) NULL,
	[DatabaseName] [varchar](100) NULL,
	[BackupType] [nvarchar](20) NULL,
	[BackupStartDate] [datetime] NULL,
	[BackupFinishDate] [datetime] NULL,
	[TotalBackupTimeMinutes] [smallint] NULL,
	[BackupSize] [decimal](15,2) NULL,
	[BackupSizeMB] [decimal](15,2) NULL,
	[collect_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_server_backup_information_sql_instance_database_name] ON [raw].[server_backup_information]
(
	[SQLInstance] ASC,
	[DatabaseName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [raw].[server_buffer_pool_extension_information]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [raw].[server_buffer_pool_extension_information]
(
	[SQLInstance] [varchar](50) NULL,
	[path] [nvarchar](256) NULL,
	[file_id] [int] NULL,
	[state] [int] NULL,
	[state_description] [nvarchar](60) NOT NULL,
	[current_size_in_kb] [bigint] NULL,
	[collect_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_server_buffer_pool_extension_information_sql_instance] ON [raw].[server_buffer_pool_extension_information]
(
	[SQLInstance] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [raw].[server_cluster_information]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [raw].[server_cluster_information]
(
	[SQLInstance] [varchar](50) NULL,
	[NodeName] [nvarchar](50) NULL,
	[collect_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_server_cluster_information_sql_instance] ON [raw].[server_cluster_information]
(
	[SQLInstance] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [raw].[server_configuration_in_use]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [raw].[server_configuration_in_use]
(
	[SQLInstance] [varchar](50) NULL,
	[ConfigurationName] [nvarchar](128) NULL,
	[State] [varchar](100) NULL,
	[collect_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_server_configuration_in_use_sql_instance] ON [raw].[server_configuration_in_use]
(
	[SQLInstance] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [raw].[server_connections_by_ip_address]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [raw].[server_connections_by_ip_address]
(
	[SQLInstance] [varchar](50) NULL,
	[ClientAddress] [nvarchar](50) NULL,
	[ProgramName] [nvarchar](128) NULL,
	[HostName] [nvarchar](50) NULL,
	[LoginName] [nvarchar](50) NULL,
	[ConnectionCount] [int] NULL,
	[collect_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_server_connections_by_ip_address_sql_instance] ON [raw].[server_connections_by_ip_address]
(
	[SQLInstance] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [raw].[server_cpu_utilization]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [raw].[server_cpu_utilization]
(
	[SQLInstance] [varchar](50) NULL,
	[record_id] [int] NULL,
	[EventTime] [datetime] NULL,
	[system_cpu_utilization] [int] NULL,
	[sql_cpu_utilization] [int] NULL,
	[collect_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_server_cpu_utilization_sql_instance] ON [raw].[server_cpu_utilization]
(
	[SQLInstance] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [raw].[server_credential_information]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [raw].[server_credential_information]
(
	[SQLInstance] [varchar](50) NULL,
	[credential_id] int NULL,
	[Credential_Name] [nvarchar](128) NULL,
	[credential_identity] [nvarchar](50) NULL,
	[Principal_Name] [nvarchar](50) NULL,
	[type_desc] [nvarchar](128) NULL,
	[is_disabled] bit NULL,
	[default_database_name] [nvarchar](128) NULL,
	[Proxy_Name] [nvarchar](128) NULL,
	[enabled] int NULL,
	[description] [nvarchar](512) NULL,
	[collect_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_server_credential_information_sql_instance] ON [raw].[server_credential_information]
(
	[SQLInstance] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [raw].[server_custom_errors_created]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [raw].[server_custom_errors_created]
(
	[SQLInstance] [varchar](50) NULL,
	[Message] [nvarchar](255) NULL,
	[ErrorID] [int] NOT NULL,
	[LanguageID] [smallint] NOT NULL,
	[ErrorSeverity] [tinyint] NULL,
	[collect_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_server_custom_errors_created_sql_instance] ON [raw].[server_custom_errors_created]
(
	[SQLInstance] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [raw].[server_database_mail_information]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [raw].[server_database_mail_information]
(
	[SQLInstance] [varchar](50) NULL,
	[ProfileName] [nvarchar](128) NULL,
	[ProfileDescription] [nvarchar](512) NULL,
	[LastModificationDate] [datetime] NULL,
	[LastModificationUser] [nvarchar](50) NULL,
	[AccountID] int NULL,
	[AccountName] [nvarchar](128) NULL,
	[AccountDescription] [nvarchar](512) NULL,
	[EmailAddress] [nvarchar](128) NULL,
	[DisplayName] [nvarchar](128) NULL,
	[ReplyToAddress] [nvarchar](128) NULL,
	[ServerType] [nvarchar](128) NULL,
	[ServerName] [nvarchar](50) NULL,
	[Port] int NULL,
	[Username] [nvarchar](50) NULL,
	[SSLEnabled] bit NULL,
	[collect_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_server_database_mail_information_sql_instance] ON [raw].[server_database_mail_information]
(
	[SQLInstance] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [raw].[server_db_snapshot_information]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [raw].[server_db_snapshot_information]
(
	[SQLInstance] [varchar](50) NULL,
	[SnapshotDatabaseName] [varchar](100) NULL,
	[SourceDatabaseName] [varchar](100) NULL,
	[create_date] [datetime] NULL,
	[collect_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_server_db_snapshot_information_sql_instance] ON [raw].[server_db_snapshot_information]
(
	[SQLInstance] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [raw].[server_deprecated_features]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [raw].[server_deprecated_features]
(
	[SQLInstance] [varchar](50) NULL,
	[DeprecatedFeature] [nvarchar](128) NULL,
	[UsageCount] int NULL,
	[collect_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_server_deprecated_features_sql_instance] ON [raw].[server_deprecated_features]
(
	[SQLInstance] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [raw].[server_event_notification_information]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [raw].[server_event_notification_information]
(
	[SQLInstance] [varchar](50) NULL,
	[name] [varchar](256) NULL,
	[object_id] [int] NOT NULL,
	[parent_class_desc] [nvarchar](60) NULL,
	[create_date] [datetime] NOT NULL,
	[service_name] [nvarchar](256) NULL,
	[collect_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_server_event_notification_information_sql_instance] ON [raw].[server_event_notification_information]
(
	[SQLInstance] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [raw].[server_linked_server_information]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [raw].[server_linked_server_information]
(
	[SQLInstance] [varchar](50) NULL,
	[LinkedServerName] [varchar](100) NULL,
	[ProviderName] [varchar](100) NULL,
	[Product] [varchar](100) NULL,
	[DataSource] [varchar](100) NULL,
	[RemoteName] [varchar](100) NULL,
	[ProviderString] [varchar](100) NULL,
	[Location] [varchar](100) NULL,
	[category] [varchar](100) NULL,
	[collect_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_server_linked_server_information_sql_instance] ON [raw].[server_linked_server_information]
(
	[SQLInstance] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [raw].[server_logshipping_information]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [raw].[server_logshipping_information]
(
	[SQLInstance] [varchar](50) NULL,
	[primary_server] [varchar](100) NULL,
	[primary_database] [varchar](100) NULL,
	[restore_delay] [int] NULL,
	[time_since_last_restore] [int] NULL,
	[last_copied_date] [datetime] NULL,
	[last_restored_date] [datetime] NULL,
	[last_copied_file] [varchar](256) NULL,
	[last_restored_file] [varchar](256) NULL,
	[disconnect_users] [bit] NULL,
	[backup_source_directory] [varchar](1024) NULL,
	[backup_destination_directory] [varchar](1024) NULL,
	[monitor_server] [varchar](100) NULL,
	[collect_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_server_logshipping_information_sql_instance] ON [raw].[server_logshipping_information]
(
	[SQLInstance] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [raw].[server_maintence_plan_information]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [raw].[server_maintenance_plan_information]
(
	[SQLInstance] [varchar](50) NULL,
	[MaintenancePlan] [nvarchar](128) NULL,
	[Description] [nvarchar](512) NULL,
	[PlanOwner] [nvarchar](50) NULL,
	[SubplanName] [nvarchar](128) NULL,
	[SubplanDescription] [nvarchar](512) NULL,
	[JobName] [nvarchar](128) NULL,
	[JobDescription] [nvarchar](512) NULL,
	[enabled] bit NULL,
	[TaskName] [nvarchar](128) NULL,
	[DatabaseName] [varchar](100) NULL,
	[collect_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_server_maintenance_plan_information_sql_instance] ON [raw].[server_maintenance_plan_information]
(
	[SQLInstance] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [raw].[server_mirroring_information]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [raw].[server_mirroring_information]
(
	[SQLInstance] [varchar](50) NULL,
	[DatabaseName] [varchar](100) NULL,
	[MirroringState] [nvarchar](60) NULL,
	[MirroringRole] [nvarchar](60) NULL,
	[MirroringSafetyLevel] [nvarchar](60) NULL,
	[MirroringPartnerName] [nvarchar](128) NULL,
	[MirroringPartnerInstance] [nvarchar](128) NULL,
	[MirroringWitnessState] [nvarchar](60) NULL,
	[collect_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_server_mirroring_information_sql_instance] ON [raw].[server_mirroring_information]
(
	[SQLInstance] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [raw].[server_pbm_information]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [raw].[server_pbm_information]
(
	[SQLInstance] [varchar](50) NULL,
	[Policy] [varchar](256) NULL,
	[Condition] [varchar](256) NULL,
	[facet] [varchar](256) NULL,
	[date_created] [datetime] NULL,
	[date_modified] [datetime] NULL,
	[execution_mode] [varchar](50) NULL,
	[collect_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_server_pbm_information_sql_instance] ON [raw].[server_pbm_information]
(
	[SQLInstance] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [raw].[server_replication_information]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [raw].[server_replication_information]
(
	[SQLInstance] [varchar](50) NULL,
	[publisher_id] [nvarchar](50) NULL,
	[publisher_db] [varchar](100) NULL,
	[PublicationName] [nvarchar](128) NULL,
	[ReplicationType] [nvarchar](50) NULL,
	[VendorName] [nvarchar](50) NULL,
	[ReplicationDescription] [nvarchar](512) NULL,
	[collect_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_server_replication_information_sql_instance] ON [raw].[server_replication_information]
(
	[SQLInstance] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [raw].[server_rg_information]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [raw].[server_rg_information]
(
	[SQLInstance] [varchar](50) NULL,
	[is_enabled] bit NULL,
	[classifier] int NULL,
	[pool_name] [nvarchar](128) NULL,
	[group_name] [nvarchar](128) NULL,
	[importance] [nvarchar](128) NULL,
	[request_max_memory_grant_percent] int NULL,
	[request_max_cpu_time_sec] int NULL,
	[min_memory_percent] int NULL,
	[max_memory_percent] int NULL,
	[min_cpu_percent] int NULL,
	[max_cpu_percent] int NULL,
	[collect_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_server_rg_information_sql_instance] ON [raw].[server_rg_information]
(
	[SQLInstance] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [raw].[server_securables]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [raw].[server_securables]
(
	[SQLInstance] [varchar](50) NULL,
	[LoginName] [varchar](100) NULL,
	[securables] [nvarchar](2500) NULL,
	[collect_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_server_securables_sql_instance] ON [raw].[server_securables]
(
	[SQLInstance] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [raw].[server_tcp_endpoints_information]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [raw].[server_tcp_endpoints_information]
(
	[SQLInstance] [varchar](50) NULL,
	[EndpointName] [sysname] NOT NULL,
	[protocol_desc] [nvarchar](60) NULL,
	[type_desc] [varchar](60) NULL,
	[collect_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_server_tcp_endpoints_information_sql_instance] ON [raw].[server_tcp_endpoints_information]
(
	[SQLInstance] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [raw].[server_tcp_port_information]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [raw].[server_tcp_port_information]
(
	[SQLInstance] [varchar](50) NULL,
	[net_transport] [nvarchar](10) NULL,
	[protocol_type] [nvarchar](10) NULL,
	[encrypt_option] [nvarchar](10) NULL,
	[auth_scheme] [nvarchar](10) NULL,
	[client_net_address] [nvarchar](50) NULL,
	[local_tcp_port] int NULL,
	[collect_date] datetime NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_server_tcp_port_information_sql_instance] ON [raw].[server_tcp_port_information]
(
	[SQLInstance] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [raw].[server_tde_information]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [raw].[server_tde_information]
(
	[SQLInstance] [varchar](50) NULL,
	[database_name] [varchar](100) NULL,
	[cert_name] [varchar](100) NULL,
	[encryption_state_desc] [varchar](256) NULL,
	[key_algorithm] [varchar](100) NULL,
	[key_length] [int] NULL,
	[collect_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_server_tde_information_sql_instance] ON [raw].[server_tde_information]
(
	[SQLInstance] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [raw].[server_trace_flag_information]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [raw].[server_trace_flag_information]
(
	[SQLInstance] [varchar](50) NULL,
	[TraceFlag] [int] NULL,
	[Status] [int] NULL,
	[Global] [int] NULL,
	[Session] [int] NULL,
	[collect_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_server_trace_flag_information_sql_instance] ON [raw].[server_trace_flag_information]
(
	[SQLInstance] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [raw].[server_trigger_information]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [raw].[server_trigger_information]
(
	[SQLInstance] [varchar](50) NULL,
	[name] [nvarchar](128) NULL,
	[parent_class_desc] [nvarchar](128) NULL,
	[type_desc] [nvarchar](50) NULL,
	[create_date] datetime NULL,
	[modify_date] datetime NULL,
	[is_ms_shipped] bit NULL,
	[is_disabled] bit NULL,
	[event_type_desc] [nvarchar](128) NULL,
	[event_group_type_desc] [nvarchar](128) NULL,
	[collect_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_server_trigger_information_sql_instance] ON [raw].[server_trigger_information]
(
	[SQLInstance] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [raw].[server_volume_information]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [raw].[server_volume_information]
(
	[SQLInstance] [varchar](50) NULL,
	[DriveLetter] [nvarchar](5) NULL,
	[FileSystem] [nvarchar](10) NULL,
	[LogicalVolumeName] [nvarchar](50) NULL,
	[TotalSizeGB] decimal(18,2) NULL,
	[AvailableSizeGB] decimal(18,2) NULL,
	[SpaceFreePercent] decimal(8,2) NULL,
	[CompressedVolume] int NULL,
	[collect_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_server_volume_information_sql_instance] ON [raw].[server_volume_information]
(
	[SQLInstance] ASC,
	[DriveLetter] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [raw].[server_volume_latency]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [raw].[server_volume_latency]
(
	[SQLInstance] [varchar](50) NULL,
	[Drive] [nvarchar](5) NULL,
	[VolumeMountPoint] [nvarchar](5) NULL,
	[ReadLatency] int NULL,
	[WriteLatency] int NULL,
	[OverallLatency] int NULL,
	[AvgBytesRead] int NULL,
	[AvgBytesWrite] int NULL,
	[AvgBytesTransfer] int NULL,
	[collect_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_server_volume_latency_sql_instance] ON [raw].[server_volume_latency]
(
	[SQLInstance] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE TABLE [raw].[database_to_server_mapping] (
    SQLInstance NVARCHAR(128),
    session_id INT,
    connect_time DATETIME,
    host_name NVARCHAR(128),
    program_name NVARCHAR(128),
    DatabaseName NVARCHAR(128),
    AuthenticatingDatabaseName NVARCHAR(128),
    login_name NVARCHAR(128),
    net_transport NVARCHAR(128),
    protocol_type NVARCHAR(128),
    encrypt_option NVARCHAR(128),
    auth_scheme NVARCHAR(128),
    date_collected DATETIME
);
GO
CREATE CLUSTERED INDEX [ix_database_to_server_mapping_sql_instance] ON [raw].[database_to_server_mapping]
(
	[SQLInstance] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE TABLE [mpa].[master_applications]
(
	[ApplicationId] [varchar](100) NOT NULL,
	[ApplicationName] [varchar](100) NOT NULL
)
GO
CREATE CLUSTERED INDEX [ix_master_applications] ON [mpa].[master_applications]
(
	[ApplicationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE TABLE [mpa].[master_databases]
(
	[SQLInstance] [varchar](50) NOT NULL,
	[DatabaseName] [varchar](100) NOT NULL,
	[ApplicationId] [varchar](50) NOT NULL,
	[Environment] [varchar](50) NOT NULL
)
GO
CREATE CLUSTERED INDEX [ix_master_databases] ON [mpa].[master_databases]
(
	[ApplicationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE TABLE [dbo].[sql_server_extended_support_list]
(
	[SQLServerVersion] [varchar](50) NOT NULL,
	[StartDate] [date] NOT NULL,
	[MainstreamEndDate] date NOT NULL,
	[ExtendedEndDate] date NOT NULL
)
GO
CREATE CLUSTERED INDEX [ix_sql_server_extended_support_list] ON [dbo].[sql_server_extended_support_list]
(
	[SQLServerVersion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE TABLE [raw].[errorlog](
	[SQLInstance] [varchar](50) NULL,
	[Category] varchar(50) NULL,
	[DatabaseName] varchar(100) NULL,
	[ScriptName] [varchar](MAX) NULL,
	[ErrorMessage] [nvarchar](MAX) NULL,
	[date_collected] datetime NULL)

GO
CREATE CLUSTERED INDEX [ix_errorlog] ON [raw].[errorlog]
(
	[SQLInstance] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE TABLE [raw].[database_extended_stored_procedure](
	[SQLInstance] [varchar](50) NULL,
	[DatabaseName] [varchar](100) NULL,
	[ProcedureName] [varchar](256) NULL,
	[Code] [nvarchar](MAX) NULL,
	[date_collected] [datetime] NULL)

GO
CREATE CLUSTERED INDEX [ix_database_extended_stored_procedure] ON [raw].[database_extended_stored_procedure]
(
	[SQLInstance] ASC,
	[DatabaseName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Object: Table [raw].[database_filetable_information] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [raw].[database_filetable_information]
(
	[SQLInstance] [varchar](50) NULL,
	[DatabaseName] [varchar](100) NULL,
	[SchemaName] [varchar](50) NULL,
	[TableName] [nvarchar](150) NULL,
	[create_date] [datetime] NULL,
	[collect_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_database_filetable_information_sql_instance] ON [raw].[database_filetable_information]
(
	[SQLInstance] ASC,
	[DatabaseName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE TABLE [dbo].[feature_supportability] (
    [Feature] [NVARCHAR](255),
    [Enterprise] [NVARCHAR](5),
    [Standard] [NVARCHAR](5),
	[SkuFeatureCode] [NVARCHAR](50),
	[Description] [NVARCHAR](MAX)
);
CREATE CLUSTERED INDEX [ix_feature_supportability] ON [dbo].[feature_supportability]
(
	[Feature] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Object:  View [dbo].[vw_logins_and_users_instance]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_logins_and_users_instance]
AS
	SELECT usr_db.SQLInstance,
		usr_db.[DatabaseName],
		usr_db.[UserType],
		usr_db.[DatabaseUser],
		ISNULL(usr_db.Roles,'N/A') as DatabaseRoles,
		ISNULL(db_sec.securables,'N/A') AS DatabaseSecurables,
		ISNULL(lg_inst.Roles,'N/A') AS ServerRoles,
		ISNULL(srv_sec.securables,'N/A') AS ServerSecurables
	FROM raw.database_user_permissions AS usr_db
		LEFT JOIN raw.server_logins_and_permissions AS lg_inst
		ON usr_db.SQLInstance = lg_inst.SQLInstance
			AND usr_db.[DatabaseUser] = lg_inst.[LoginName]
		LEFT JOIN raw.server_securables as srv_sec
		ON usr_db.SQLInstance = srv_sec.SQLInstance
			AND usr_db.[DatabaseUser] = srv_sec.[LoginName]
		LEFT JOIN raw.database_user_securables as db_sec
		ON usr_db.SQLInstance = db_sec.SQLInstance
			AND usr_db.[DatabaseUser] = db_sec.[UserName]

GO


/****** Object:  StoredProcedure [dbo].[ConfirmDatabaseInterdependency]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [mpa].[ConfirmDatabaseInterdependency]
	(@SQLInstance VARCHAR(100),
	@DatabaseName VARCHAR(100))
AS
/*
-- =============================================
-- Author:      Marcos Freccia
-- Create date: 11.11.2021
-- Description: This procedure is only used for generating the ADM Questionnaire Spreadsheet - Database Interdependency
-- =============================================
*/
create table #reference_database
(
	SQLInstance varchar(100),
	referencing_database_name varchar(100),
	referenced_server_name varchar(50),
	referenced_database_name varchar(100),
	objects_in_use varchar(MAX)
)


INSERT INTO #reference_database
SELECT DISTINCT SQLInstance, referencing_database_name, referenced_server_name, referenced_database_name
, (SELECT DISTINCT referencing_object_type, referencing_object_name
	FROM raw.database_direct_reference_information as ref2
	where ref1.SQLInstance = ref2.SQLInstance AND ref1.referencing_database_name = ref2.referencing_database_name
		AND ref1.referenced_database_location = ref2.referenced_database_location
		AND ref1.referenced_database_name = ref2.referenced_database_name
	FOR JSON PATH)
FROM raw.database_direct_reference_information as ref1
WHERE SQLInstance = @SQLInstance
	AND referencing_database_name = @DatabaseName
	AND referenced_database_location <> 'Internal'

INSERT INTO #reference_database
SELECT DISTINCT SQLInstance, referencing_database_name, referenced_server_name, referenced_database_name
, (SELECT DISTINCT referencing_object_type, referencing_object_name
	FROM raw.database_direct_reference_information as ref2
	WHERE ref1.SQLInstance = ref2.SQLInstance AND ref1.referenced_database_name = ref2.referenced_database_name
		AND ref1.referenced_database_location = ref2.referenced_database_location
		AND ref1.referencing_database_name = ref2.referencing_database_name
	FOR JSON PATH)
FROM raw.database_direct_reference_information as ref1
WHERE SQLInstance = @SQLInstance
	AND referenced_database_name = @DatabaseName
	AND referenced_database_location <> 'Internal'



SELECT r1.*
INTO #database_dependency
FROM #reference_database as r1
	INNER JOIN #reference_database r2
	ON r1.SQLInstance = r2.SQLInstance
		AND r1.referencing_database_name = r2.referencing_database_name
		AND r1.referenced_database_name = r2.referenced_database_name
		AND r1.referenced_server_name = r2.referenced_server_name
		AND r1. referencing_database_name <> r2.referenced_database_name;

SELECT ref.SQLInstance, ref.referencing_database_name, ref.referenced_server_name, ref.referenced_database_name, objects_in_use
FROM #database_dependency as ref
ORDER BY ref.SQLInstance,ref.referencing_database_name

GO

/****** Object:  StoredProcedure [dbo].[ConfirmRDSSupport]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [mpa].[ConfirmRDSSupport]
	(@SQLInstance VARCHAR(50))
AS
DECLARE @RGExists BIT;
DECLARE @MaintPlanExists BIT;
DECLARE @PBMExists BIT;
DECLARE @DBSnapsMExists BIT;
DECLARE @ServerTriggerExists BIT;
DECLARE @XpCMDShellExists BIT;
DECLARE @BufferPoolExtensionExists BIT;
DECLARE @StretchDBExists BIT;
DECLARE @ServiceBrokerEndpointExists BIT;
DECLARE @LogShippingExists BIT;
DECLARE @ReplicationExists BIT;
DECLARE @TCPEndpointExists BIT;
DECLARE @PolybaseExists BIT;
DECLARE @MachineLearningExists BIT;
DECLARE @DQSExists BIT;
DECLARE @PerfDataCollectorExists BIT;
DECLARE @CLRSupport BIT;
DECLARE @StorageSize BIT;
DECLARE @VersionSupport BIT;
DECLARE @FilestreamExists BIT;
DECLARE @FileTableExists BIT;

DECLARE @RDSStorageLimit INT = 256000;


-- Performance Data Collector
SET @PerfDataCollectorExists = (SELECT COUNT(*)
FROM raw.server_agent_jobs_information
WHERE JobName IN ('sysutility_get_cache_tables_data_into_aggregate_tables_daily',
								'sysutility_get_cache_tables_data_into_aggregate_tables_hourly',
								'sysutility_get_views_data_into_cache_tables')
	AND SQLInstance = @SQLInstance)

-- PolyBase
SET @PolybaseExists = (SELECT COUNT(*)
FROM raw.server_general_information
WHERE IsPolyBaseInstalled = 1 AND SQLInstance = @SQLInstance)


-- Machine Learning and R Services (requires OS access to install it)
SET @MachineLearningExists = (SELECT COUNT(*)
FROM raw.server_configuration_in_use
WHERE [ConfigurationName] = 'external scripts enabled'
	AND SQLInstance = @SQLInstance AND State = 1)

-- Data Quality Services
SET @DQSExists = (SELECT COUNT(*)
FROM raw.database_general_information
WHERE [DatabaseName] IN ('DQS_MAIN','DQS_PROJECTS','DQS_STAGING_DATA')
	AND SQLInstance = @SQLInstance)

-- Replication
SET @ReplicationExists = (SELECT COUNT(*)
FROM raw.server_replication_information
WHERE SQLInstance = @SQLInstance)

-- T-SQL endpoints (all operations using CREATE ENDPOINT are unavailable)
SET @TCPEndpointExists = (SELECT COUNT(*)
FROM raw.server_tcp_endpoints_information
WHERE SQLInstance = @SQLInstance AND type_desc <> 'SERVICE_BROKER')


-- Stretch database
SET @StretchDBExists = (SELECT COUNT(*)
FROM raw.database_general_information
WHERE SQLInstance = @SQLInstance AND StretchDatabaseEnabled = 'True')

-- Service Broker endpoints
SET @ServiceBrokerEndpointExists = (SELECT COUNT(*)
FROM raw.server_tcp_endpoints_information
WHERE SQLInstance = @SQLInstance AND type_desc = 'SERVICE_BROKER')

-- Database Log Shipping
SET @LogShippingExists = (SELECT COUNT(*)
FROM raw.server_logshipping_information
WHERE SQLInstance = @SQLInstance)


-- Buffer pool extension
SET @BufferPoolExtensionExists = (SELECT COUNT(*)
FROM raw.server_buffer_pool_extension_information
WHERE SQLInstance = @SQLInstance)

--Extended stored procedures, including xp_cmdshell
SET @XpCMDShellExists = (SELECT COUNT(*)
FROM raw.server_configuration_in_use
WHERE SQLInstance = @SQLInstance
	AND [ConfigurationName] = 'xp_cmdshell' and State = 1)

-- Resource Governor
SET @RGExists = ( SELECT COUNT(*) AS [exists]
FROM raw.server_rg_information
WHERE is_enabled = 'True' AND SQLInstance = @SQLInstance)

-- Maintenance plans
SET @MaintPlanExists = (SELECT COUNT(*)
FROM raw.server_maintenance_plan_information
WHERE SQLInstance = @SQLInstance
	AND MaintenancePlan NOT LIKE '%system databases%'
	AND MaintenancePlan NOT LIKE '%backup%'
	AND MaintenancePlan NOT LIKE '%Rebuild%'
	AND MaintenancePlan NOT LIKE '%Reindex%'
	AND MaintenancePlan NOT LIKE '%DBA_CheckDb%'
	AND TaskName NOT LIKE '%Reindex%'
	AND TaskName NOT LIKE '%Rebuild%'
	AND TaskName NOT LIKE '%Shrink%'
	AND TaskName NOT LIKE '%Database Integrity%'
	AND TaskName NOT LIKE '%Update Statistics%')


-- Policy-Based Management
SET @PBMExists = (SELECT COUNT(*)
FROM raw.server_pbm_information
WHERE SQLInstance = @SQLInstance)

-- Database Snapshot
SET @DBSnapsMExists = (SELECT COUNT(*)
FROM raw.server_db_snapshot_information
WHERE SQLInstance = @SQLInstance)


-- Server-level triggers
SET @ServerTriggerExists = (SELECT COUNT(*)
FROM raw.server_trigger_information
WHERE SQLInstance = @SQLInstance)


SET @CLRSupport = (SELECT DISTINCT CASE
				   WHEN gen_db.SQLServerMajorVersion IN ('SQL Server 2019','SQL Server 2017','SQL Server 2022', 'SQL Server 2025')
				   THEN 1
				   ELSE 0
				   END as clr_support
FROM dbo.vw_database_general_information as gen_db
	JOIN raw.database_clr_information as clr
	ON gen_db.SQLInstance = clr.SQLInstance
		AND gen_db.DatabaseName = clr.DatabaseName
		AND clr.ObjectName IS NOT NULL
		AND gen_db.SQLInstance = @SQLInstance)


SET @StorageSize = (SELECT
	CASE
        WHEN SUM(CAST(TotalSizeinMB AS INT)) / 1024 <= (@RDSStorageLimit * 0.65) THEN 0
        WHEN SUM(CAST(TotalSizeinMB AS INT)) / 1024 >= (@RDSStorageLimit * 0.66) THEN 1
    END AS StorageStatus
FROM raw.database_size_information WHERE SQLInstance = @SQLInstance
AND DatabaseName NOT IN ('msdb','model','master','tempdb'))

SET @VersionSupport = (SELECT
	CASE
		WHEN ext.MainstreamEndDate BETWEEN CAST(GETDATE() AS DATE) AND DATEADD(MONTH,12,CAST(GETDATE() AS DATE)) THEN 1
		WHEN ext.ExtendedEndDate BETWEEN CAST(GETDATE() AS DATE) AND DATEADD(MONTH,12,CAST(GETDATE() AS DATE)) THEN 1
		WHEN ext.ExtendedEndDate  <= CAST(GETDATE() AS DATE) THEN 1
		WHEN ext.ExtendedEndDate  > DATEADD(MONTH,12,CAST(GETDATE() AS DATE)) THEN 0
		ELSE 0
		END
from raw.server_general_information as srv
join dbo.sql_server_extended_support_list as ext
on srv.SQLServerMajorVersion = ext.SQLServerVersion
AND SQLInstance = @SQLInstance)

-- FILESTREAM (unsupported on RDS)
SET @FilestreamExists = (SELECT CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END
FROM raw.database_filestream_information
WHERE SQLInstance = @SQLInstance)

-- File Tables (unsupported on RDS)
SET @FileTableExists = (SELECT CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END
FROM raw.database_filetable_information
WHERE SQLInstance = @SQLInstance)

SELECT @SQLInstance AS SQLInstance, @RGExists AS ResourceGovernor, @MaintPlanExists AS MaintenancePlans, @PBMExists AS PolicyBasedManagement,
	   @DBSnapsMExists AS DatabaseSnapshots, @ServerTriggerExists AS ServerTriggers, @XpCMDShellExists AS XPCmdShell,
	   @BufferPoolExtensionExists AS BufferPoolExtension, @StretchDBExists AS StretchDatabase,
	   @ServiceBrokerEndpointExists AS ServiceBrokerEnpoints, @LogShippingExists AS LogShipping,
	   @ReplicationExists AS [Replication], @TCPEndpointExists AS TCPEndpoints, @PolybaseExists AS Polybase,
	   @MachineLearningExists AS MachineLearningServices, @DQSExists AS DataQualityServices,
	   @PerfDataCollectorExists AS PerformanceDataCollector, ISNULL(@CLRSupport,0) as CLRSupport,
	   @StorageSize as StorageSize,@VersionSupport as VersionSupport,
	   @FilestreamExists AS Filestream,
	   @FileTableExists AS FileTables
GO
/****** Object:  StoredProcedure [dbo].[ConfirmSPConfigure]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [mpa].[ConfirmSPConfigure]
	(@SQLInstance VARCHAR(50))
AS
/*
-- =============================================
-- Author:      Marcos Freccia
-- Create date: 20.10.2021
-- Description: This procedure is only used for generating the ADM Questionnaire Spreadsheet - Non-Default sp_configure
-- =============================================
*/
SELECT custom_sp_configure.SQLInstance, custom_sp_configure.[ConfigurationName], def.State AS DefaultValue,
	custom_sp_configure.State AS InUseValue
FROM raw.server_configuration_in_use AS custom_sp_configure
	LEFT JOIN dbo.default_sp_configure AS def
	ON custom_sp_configure.[ConfigurationName] = def.ConfigurationName
WHERE custom_sp_configure.[ConfigurationName] NOT IN ('max server memory (MB)','min server memory (MB)')
	AND def.State IS NOT NULL
	AND def.State <> custom_sp_configure.State
	AND custom_sp_configure.SQLInstance = @SQLInstance
GO

/****** Object:  StoredProcedure [adm].[ConfirmSSISPackages]    Script Date: 3/28/2022 11:15:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [mpa].[ConfirmSSISPackages]
	(@SQLInstance VARCHAR(50))
AS
/*
-- =============================================
-- Author:      Marcos Freccia
-- Create date: 19.10.2021
-- Description: This procedure is only used for generating the ADM Questionnaire Spreadsheet - Confirm SSIS Packages tab
-- =============================================
*/
SELECT SQLInstance, [RootFolder] as 'Root Folder', [FullPath] as 'Full Path', [PackageName],
	Description, [Package Deployment Type],
	RDSNonSupportedComponents,
	NULL AS Migrate,
	NULL ExtraNotes
FROM dbo.vw_ssis_package_information
WHERE SQLInstance = @SQLInstance
GO

/****** Object:  StoredProcedure [adm].[ConfirmLinkedServers]    Script Date: 3/28/2022 11:15:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [mpa].[ConfirmLinkedServers]
	(@SQLInstance VARCHAR(50))
AS
/*
-- =============================================
-- Author:      Marcos Freccia
-- Create date: 19.10.2021
-- Description: This procedure is only used for generating the ADM Questionnaire Spreadsheet - Confirm Linked Servers tab
-- =============================================
*/
SELECT SQLInstance,
	[LinkedServerName],
	[ProviderName],
	Product,
	[DataSource],
	[RemoteName],
	[ProviderString],
	NULL AS Migrate,
	NULL as ExtraNotes
FROM raw.server_linked_server_information
WHERE SQLInstance = @SQLInstance;
GO

/****** Object:  StoredProcedure [dbo].[ConfirmSSRSReports]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [mpa].[ConfirmSSRSReports]
	(@SQLInstance VARCHAR(50))
AS
/*
-- =============================================
-- Author:      Marcos Freccia
-- Create date: 19.10.2021
-- Description: This procedure is only used for generating the ADM Questionnaire Spreadsheet - Confirm SSRS Reports tab
-- =============================================
*/
SELECT SQLInstance, TypeName, [Path], [Name], CreatedBy
FROM raw.database_ssrs_reports_information
WHERE SQLInstance = @SQLInstance
GO

/****** Object:  StoredProcedure [mpa].[ConfirmDatabaseUsers]    Script Date: 3/28/2022 11:15:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE mpa.[ConfirmDatabaseUsers]
	(@ApplicationName VARCHAR(100),
	@Environment VARCHAR(50))
AS
/*
-- =============================================
-- Author:      Marcos Freccia
-- Create date: 27.11.2023
-- Description: This procedure is only used for generating the ADM Questionnaire Spreadsheet - Users to Migrate
-- =============================================
*/
DECLARE @ApplicationId VARCHAR(50)
SET @ApplicationId = (select distinct master_app.ApplicationId
FROM mpa.master_applications as master_app
JOIN mpa.master_databases as master_db
ON master_app.ApplicationId = master_db.ApplicationId
WHERE master_app.ApplicationName = @ApplicationName AND master_db.Environment = @Environment)

DECLARE @SQLInstance TABLE (SQLInstance VARCHAR(50))
INSERT INTO @SQLInstance
SELECT SQLInstance
FROM mpa.master_databases
where ApplicationID = @ApplicationId

	select vw.*,
		'YES' AS [Migrate],
		NULL as ExtraNotes
	FROM dbo.vw_logins_and_users_instance as vw
		join mpa.master_databases as master_db
		on vw.SQLInstance = master_db.SQLInstance
			and vw.DatabaseName = master_db.DatabaseName
		join mpa.master_applications as app
		on master_db.ApplicationId = app.ApplicationId
	WHERE app.ApplicationName = @ApplicationName AND master_db.Environment = @Environment
		AND [DatabaseUser] NOT IN (SELECT login_name
		FROM dbo.logins_exclusion_list)
UNION
	SELECT *,
		'YES' AS [Migrate],
		NULL as ExtraNotes
	FROM dbo.vw_logins_and_users_instance
	WHERE SQLInstance IN(SELECT SQLInstance
		FROM @SQLInstance)
		and DatabaseName IN('master','model','msdb','tempdb')
GO


CREATE PROCEDURE mpa.[ConfirmCLRUsage]
	(@ApplicationName VARCHAR(100),
	@Environment VARCHAR(50))
AS
/*
-- =============================================
-- Author:      Marcos Freccia
-- Create date: 27.11.2023
-- Description: This procedure is only used for generating the ADM Questionnaire Spreadsheet - Confirm CLR Usage
-- =============================================
*/
SELECT gen_db.SQLInstance,
	gen_db.DatabaseName,
	clr.SchemaName,
	clr.ObjectName,
	clr.PermissionSetDesc,
	clr.TypeDesc,
	NULL AS [Migrate],
	NULL as ExtraNotes
FROM dbo.vw_database_general_information as gen_db
	LEFT JOIN raw.database_clr_information as clr
	ON gen_db.SQLInstance = clr.SQLInstance
		AND gen_db.DatabaseName = clr.DatabaseName
	join mpa.master_databases as master_db
	on gen_db.SQLInstance = master_db.SQLInstance
		and gen_db.DatabaseName = master_db.DatabaseName
	join mpa.master_applications as master_app
	on master_db.ApplicationId = master_app.ApplicationId
WHERE master_app.ApplicationName = @ApplicationName
	AND master_db.Environment = @Environment
	AND clr.AssemblyName IS NOT NULL
GO


/****** Object:  StoredProcedure [mpa].[ConfirmDatabaseMail]    Script Date: 3/28/2022 11:15:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [mpa].[ConfirmDatabaseMail]
	(@SQLInstance VARCHAR(50))
AS
/*
-- =============================================
-- Author:      Marcos Freccia
-- Create date: 19.10.2021
-- Description: This procedure is only used for generating the ADM Questionnaire Spreadsheet - Confirm Database Mail tab
-- =============================================
*/
SELECT dbmail.SQLInstance,
	dbmail.[ProfileName],
	dbmail.[ProfileDescription],
	dbmail.[AccountName],
	dbmail.[EmailAddress],
	dbmail.[DisplayName],
	dbmail.[ServerType],
	dbmail.[ServerName],
	dbmail.Port,
	NULL AS [Migrate],
	NULL as ExtraNotes
FROM raw.server_database_mail_information as dbmail
WHERE dbmail.SQLInstance = @SQLInstance;
GO

/****** Object:  StoredProcedure [mpa].[ConfirmAgentJobs]    Script Date: 3/28/2022 11:15:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE mpa.[ConfirmAgentJobs]
	(@ApplicationName VARCHAR(100),
	@Environment VARCHAR(50))
AS
/*
-- =============================================
-- Author:      Marcos Freccia
-- Create date: 27.11.2023
-- Description: This procedure is only used for generating the ADM Questionnaire Spreadsheet - Confirm SQL Server Agent Jobs tab
-- =============================================
*/

SELECT DISTINCT agt_job.SQLInstance,
	master_db.Environment,
	agt_job.[DatabaseName],
	agt_job.JobName,
	JobEnabled,
	subsystems_used,
	proxy.[ProxyName],
	proxy.[CredentialIdentity],
	NULL AS Migrate,
	NULL as ExtraNotes
FROM dbo.vw_database_agent_job_information as agt_job
	LEFT JOIN raw.server_proxy_agent_information as proxy
	ON agt_job.SQLInstance = proxy.SQLInstance
		AND agt_job.JobName = proxy.[JobName]
	INNER JOIN mpa.master_databases as master_db
	ON agt_job.SQLInstance = master_db.SQLInstance
		AND agt_job.DatabaseName = master_db.DatabaseName
	INNER JOIN mpa.master_applications as master_app
	ON master_app.ApplicationId = master_db.ApplicationId
WHERE master_app.ApplicationName = @ApplicationName
	AND master_db.Environment = @Environment
ORDER BY agt_job.SQLInstance,
         [DatabaseName],
         JobName;
GO


/****** Object:  StoredProcedure [adm].[ConfirmCredentials]    Script Date: 3/28/2022 11:15:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE mpa.[ConfirmCredentials]
	(@ApplicationName VARCHAR(50),
	@Environment VARCHAR(50))
AS
/*
-- =============================================
-- Author:      Marcos Freccia
-- Create date: 27.11.2023
-- Description: This procedure is only used for generating the ADM Questionnaire Spreadsheet - Confirm Server Credentials
-- =============================================
*/
SELECT DISTINCT
	srv_cred.SQLInstance,
	srv_cred.Credential_Name as CredentialName,
	srv_cred.credential_identity as CredentialIdentity,
	NULL as Migrate,
	NULL as ExtraNotes
FROM dbo.vw_logins_and_users_instance as vw_login_usr
	JOIN raw.server_credential_information as srv_cred
	on vw_login_usr.SQLInstance = srv_cred.SQLInstance
	join mpa.master_databases as master_db
	on vw_login_usr.SQLInstance = master_db.SQLInstance
		and vw_login_usr.DatabaseName = master_db.DatabaseName
	join mpa.master_applications as master_app
	on master_db.ApplicationId = master_app.ApplicationId
		AND srv_cred.credential_identity = vw_login_usr.[DatabaseUser]
WHERE master_app.ApplicationName = @ApplicationName
	AND master_db.Environment = @Environment;

GO

CREATE PROCEDURE [mpa].[ConfirmDowngradeToStandard](@SQLInstance VARCHAR(50),@DatabaseName VARCHAR(100))
AS
DECLARE @ScoreForNo DECIMAL(10,2) = 0;
DECLARE @ScoreForYes DECIMAL(10,2) = 1;
DECLARE @ScoreForOther DECIMAL(10,2) = 0.5;

WITH AggregatedCTE AS (
    SELECT
        db_down.SQLInstance,
        gen_srv.SQLServerMajorVersion,
        gen_srv.ProductLevel,
        db_down.DatabaseName,
        fs.Feature,
        CASE
            WHEN gen_srv.SQLServerMajorVersion IN ('SQL Server 2014','SQL Server 2012','SQL Server 2008','SQL Server 2008 R2') THEN 'NO'
			WHEN gen_srv.SQLServerMajorVersion IN ('SQL Server 2016','SQL Server 2017','SQL Server 2019','SQL Server 2022', 'SQL Server 2025') THEN fs.Standard
            ELSE 'YES'
        END as DowngradePossible
    FROM
        raw.database_downgrade_to_standard AS db_down
    JOIN
        raw.server_general_information AS gen_srv
    ON
        db_down.SQLInstance = gen_srv.SQLInstance
    JOIN
        dbo.feature_supportability AS fs
    ON
        db_down.FeatureName = fs.SkuFeatureCode
    WHERE
        (gen_srv.SQLServerEdition LIKE 'Developer%' OR gen_srv.SQLServerEdition LIKE 'Enterprise%')
	AND db_down.SQLInstance = @SQLInstance
	AND db_down.DatabaseName = @DatabaseName
)
SELECT
    SQLInstance,
    SQLServerMajorVersion,
    ProductLevel,
    DatabaseName,
    JSON_QUERY('[' + STRING_AGG('{"FeatureName":"' + Feature + '", "DowngradePossible":"' + DowngradePossible + '", "DowngradeSuccessProbability": ' +
        CASE
            WHEN DowngradePossible = 'NO' THEN CAST(@ScoreForNo as varchar)
            WHEN DowngradePossible = 'YES' THEN CAST(@ScoreForYes as varchar)
            ELSE CAST(@ScoreForOther as varchar)
        END + '}', ',') + ']') AS Features,
    CAST(SUM(CASE
            WHEN DowngradePossible = 'NO' THEN @ScoreForNo
            WHEN DowngradePossible = 'YES' THEN @ScoreForYes
            ELSE @ScoreForOther
        END) as FLOAT) / COUNT(*) * 100 AS PercentageOfSuccess,
		NULL as Migrate,
		NULL as ExtraNotes
FROM
    AggregatedCTE
GROUP BY
    SQLInstance,
    SQLServerMajorVersion,
    ProductLevel,
    DatabaseName;

GO

CREATE PROCEDURE mpa.[GeneralInformation]
(@ApplicationName VARCHAR(50),@Environment VARCHAR(50))
AS
/*
-- =============================================
-- Author:      Marcos Freccia
-- Create date: 19.10.2021
-- Description: This procedure is only used for generating the ADM Questionnaire Spreadsheet - General Information tab
-- =============================================
*/
DECLARE @RDSEndpointName VARCHAR(100) = NULL
DECLARE @Tags VARCHAR(1024) = NULL
DECLARE @databases varchar(1024)
SET @databases = ''


select @databases = @databases + master_db.DatabaseName + ', '  from mpa.master_databases as master_db
join mpa.master_applications as master_app
on master_db.ApplicationId = master_app.ApplicationId
join dbo.vw_database_general_information as vw_db
ON master_db.DatabaseName = vw_db.DatabaseName
AND master_db.SQLInstance = vw_db.SQLInstance
WHERE ApplicationName = @ApplicationName
      AND Environment = @Environment;

SELECT master_app.ApplicationId,
       ApplicationName,
       Environment,
       NULL as [AWS Account ID],
       NULL as [AWS Account],
       vw_db.SQLInstance,
       vw_db.[DatabaseName],
	   DatabaseCollation,
       TotalSizeMB,
       [SQLServerMajorVersion],
       [SQLServerEdition],
       CASE
           WHEN SSRSDeployed = 1 THEN
               'YES'
           WHEN SSRSDeployed = 0 THEN
               'NO'
       END AS SSRSDeployed,
       CASE
           WHEN SSASDeployed = 1 THEN
               'YES'
           WHEN SSASDeployed = 0 THEN
               'NO'
       END AS SSASDeployed,
       CASE
           WHEN SSISDeployed = 1 THEN
               'YES'
           WHEN SSISDeployed = 0 THEN
               'NO'
       END AS SSISDeployed,
       TimezoneConfiguration,
	   @Tags AS Tags,
	   (SELECT dbo.ufn_RDSInstanceRecommendation(SUBSTRING(@databases, 0, LEN(@databases)),vw_db.SQLInstance)) AS RDSRecommendedInstances,
       NULL AS [DowngradeToStandardEdition],
	   NULL AS [SCTReportValidated],
	   @RDSEndpointName as RDSEndpointName,
	   NULL as TargetPlatform,
	   NULL as MigrationPattern,
	   NULL as MultiAZ,
	   NULL AS Migrate,
	   NULL as ExtraNotes
FROM dbo.vw_database_general_information as vw_db
JOIN mpa.master_databases as master_db
ON vw_db.SQLInstance = master_db.SQLInstance
AND vw_db.DatabaseName = master_db.DatabaseName
JOIN mpa.master_applications as master_app
on master_app.ApplicationId = master_db.ApplicationId
WHERE ApplicationName = @ApplicationName
      AND Environment = @Environment;
GO


/****** Object:  StoredProcedure [dbo].[FixSSIS_packages_connection_type_ssisdb]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[FixSSIS_packages_connection_type_ssisdb]
AS
UPDATE [raw].[ssis_packages_connection_type_ssisdb] SET PackageName = REPLACE(PackageName,'%20',' ');

DELETE FROM [raw].[ssis_packages_connection_type_ssisdb]
WHERE ConnectionType = 'Microsoft.SqlServer.Dts.Tasks.ExecuteSQLTask.ExecuteSQLTask, Microsoft.SqlServer.SQLTask, Version=11.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91'

DELETE FROM [raw].[ssis_packages_connection_type_ssisdb]
WHERE ConnectionType = 'SSIS.ExecutePackageTask.3'

update [raw].[ssis_packages_connection_type_msdb]  set ConnectionType = NULL WHERE ConnectionType = 'N/A';
update [raw].[ssis_packages_connection_type_msdb]  set TaskType = NULL WHERE TaskType = 'N/A';

WITH
	cte
	AS
	(
		SELECT
			db.SQLInstance,
			db.DatabaseName,
			ROW_NUMBER() OVER (
            PARTITION BY
        db.SQLInstance,
        db.DatabaseName
            ORDER BY
			        db.SQLInstance,
        db.DatabaseName
        ) row_num
		FROM
			raw.database_general_information as db
	)
DELETE FROM cte
WHERE row_num > 1
GO
/****** Object:  StoredProcedure [dbo].[spCleanUpAssessmentDatabase]    Script Date: 2/2/2023 6:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[spCleanUpAssessmentDatabase]
AS
DECLARE @name VARCHAR(100)
-- database name

DECLARE db_cursor CURSOR FOR
SELECT CONCAT('TRUNCATE TABLE ',sch.name,'.',tb.name) AS SQLScript
FROM sys.schemas AS sch
	JOIN sys.tables AS tb
	ON tb.schema_id = sch.schema_id
WHERE sch.name = 'raw'

OPEN db_cursor
FETCH NEXT FROM db_cursor INTO @name

WHILE @@FETCH_STATUS = 0
BEGIN
	PRINT(@name)
	EXEC(@name)

	FETCH NEXT FROM db_cursor INTO @name
END

CLOSE db_cursor
DEALLOCATE db_cursor
GO

-- Insert rows into table 'rds_instance_sizes'
INSERT INTO dbo.rds_instance_sizes
	([instance_type], [vcpu], [memory],[network_performance])
VALUES
	('db.r6g.large', '2', '16', 'Up to 10'),
	('db.r6g.xlarge', '4', '32', 'Up to 10'),
	('db.r6g.2xlarge', '8', '64', 'Up to 10'),
	('db.r6g.4xlarge', '16', '128', 'Up to 10'),
	('db.r6g.8xlarge', '32', '256', '12'),
	('db.r6g.12xlarge', '48', '384', '20'),
	('db.r6i.large', '2', '16', 'Up to 12.5'),
	('db.r6i.xlarge', '4', '32', 'Up to 12.5'),
	('db.r6i.2xlarge', '8', '64', 'Up to 12.5'),
	('db.r6i.4xlarge', '16', '128', 'Up to 12.5'),
	('db.r6i.8xlarge', '32', '256', '12.5')


GO

INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'recovery interval (min)','0')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'allow updates','0')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'user connections','0')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'locks','0')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'open objects','0')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'fill factor (%)','0')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'disallow results from triggers','0')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'nested triggers','1')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'server trigger recursion','1')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'remote access','1')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'default language','0')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'cross db ownership chaining','0')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'max worker threads','0')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'network packet size (B)','4096')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'show advanced options','0')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'remote proc trans','0')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'c2 audit mode','0')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'default full-text language','1033')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'two digit year cutoff','2049')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'index create memory (KB)','0')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'priority boost','0')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'remote login timeout (s)','10')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'remote query timeout (s)','600')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'cursor threshold','-1')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'set working set size','0')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'user options','0')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'affinity mask','0')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'max text repl size (B)','65536')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'media retention','0')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'cost threshold for parallelism','5')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'max degree of parallelism','4')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'min memory per query (KB)','1024')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'query wait (s)','-1')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'min server memory (MB)','16')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'max server memory (MB)','2147483647')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'query governor cost limit','0')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'lightweight pooling','0')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'scan for startup procs','0')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'affinity64 mask','0')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'affinity I/O mask','0')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'affinity64 I/O mask','0')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'transform noise words','0')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'precompute rank','0')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'PH timeout (s)','60')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'clr enabled','0')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'max full-text crawl range','4')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'ft notify bandwidth (min)','0')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'ft notify bandwidth (max)','100')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'ft crawl bandwidth (min)','0')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'ft crawl bandwidth (max)','100')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'default trace enabled','1')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'blocked process threshold (s)','0')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'in-doubt xact resolution','0')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'remote admin connections','0')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'common criteria compliance enabled','0')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'EKM provider enabled','0')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'backup compression default','0')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'filestream access level','0')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'optimize for ad hoc workloads','0')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'access check cache bucket count','0')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'access check cache quota','0')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'backup checksum default','0')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'automatic soft-NUMA disabled','0')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'external scripts enabled','0')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'clr strict security','1')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'column encryption enclave type','0')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'tempdb metadata memory-optimized','0')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'ADR cleaner retry timeout (min)','0')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'ADR Preallocation Factor','0')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'Agent XPs','0')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'Database Mail XPs','0')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'SMO and DMO XPs','1')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'Ole Automation Procedures','0')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'xp_cmdshell','0')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'Ad Hoc Distributed Queries','0')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'Replication XPs','0')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'contained database authentication','0')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'hadoop connectivity','0')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'polybase network encryption','1')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'remote data archive','0')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'allow polybase export','0')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'allow filesystem enumeration','1')
INSERT INTO dbo.default_sp_configure (ConfigurationName, [State]) VALUES( 'polybase enabled','0')

GO
INSERT INTO dbo.sql_server_extended_support_list(SQLServerVersion,StartDate,MainstreamEndDate,ExtendedEndDate) VALUES('SQL Server 2005','2006-01-14','2011-04-12','2016-04-12')
INSERT INTO dbo.sql_server_extended_support_list(SQLServerVersion,StartDate,MainstreamEndDate,ExtendedEndDate) VALUES('SQL Server 2008','2008-11-06','2014-07-08','2019-07-09')
INSERT INTO dbo.sql_server_extended_support_list(SQLServerVersion,StartDate,MainstreamEndDate,ExtendedEndDate) VALUES('SQL Server 2008 R2','2010-07-20','2014-07-08','2019-07-09')
INSERT INTO dbo.sql_server_extended_support_list(SQLServerVersion,StartDate,MainstreamEndDate,ExtendedEndDate) VALUES('SQL Server 2012','2012-05-20','2017-06-11','2022-07-12')
INSERT INTO dbo.sql_server_extended_support_list(SQLServerVersion,StartDate,MainstreamEndDate,ExtendedEndDate) VALUES('SQL Server 2014','2014-06-05','2019-07-05','2024-07-09')
INSERT INTO dbo.sql_server_extended_support_list(SQLServerVersion,StartDate,MainstreamEndDate,ExtendedEndDate) VALUES('SQL Server 2016','2016-06-01','2021-07-13','2026-07-14')
INSERT INTO dbo.sql_server_extended_support_list(SQLServerVersion,StartDate,MainstreamEndDate,ExtendedEndDate) VALUES('SQL Server 2017','2017-09-29','2022-10-11','2027-10-12')
INSERT INTO dbo.sql_server_extended_support_list(SQLServerVersion,StartDate,MainstreamEndDate,ExtendedEndDate) VALUES('SQL Server 2019','2019-11-04','2025-02-28','2030-01-08')
INSERT INTO dbo.sql_server_extended_support_list(SQLServerVersion,StartDate,MainstreamEndDate,ExtendedEndDate) VALUES('SQL Server 2022','2022-11-16','2028-01-11','2033-01-11')
INSERT INTO dbo.sql_server_extended_support_list(SQLServerVersion,StartDate,MainstreamEndDate,ExtendedEndDate) VALUES('SQL Server 2025','2025-11-18','2031-01-06','2036-01-06')
GO

-- Inserting data into dbo.feature_supportability table
INSERT INTO dbo.feature_supportability (Feature, Enterprise, Standard,SkuFeatureCode,Description)
VALUES
('Change data capture', 'Yes', 'Yes 1', 'ChangeCapture','1 Applies to SQL Server 2016 (13.x) SP1 as part of creating a common programmability surface area (CPSA) across editions.'),
('Columnstore', 'Yes', 'Yes 2', 'ColumnStoreIndex','Applies to SQL Server 2016 (13.x) SP1 as part of creating a Common Programmability Surface Area (CPSA) across editions. Aggregate Pushdown, String Predicate Pushdown, and SIMD Optimizations are SQL Server Enterprise Edition scalability enhancements. For more detail, see Columnstore indexes - what''s new.'),
('Data compression', 'Yes', 'Yes 2', 'Compression','Applies to SQL Server 2016 (13.x) SP1 as part of creating a Common Programmability Surface Area (CPSA) across editions. Aggregate Pushdown, String Predicate Pushdown, and SIMD Optimizations are SQL Server Enterprise Edition scalability enhancements. For more detail, see Columnstore indexes - what''s new.'),
('Multiple Filestream containers', 'Yes', 'Yes 2', 'MultipleFSContainers','Applies to SQL Server 2016 (13.x) SP1 as part of creating a Common Programmability Surface Area (CPSA) across editions. Aggregate Pushdown, String Predicate Pushdown, and SIMD Optimizations are SQL Server Enterprise Edition scalability enhancements. For more detail, see Columnstore indexes - what''s new.'),
('In-Memory OLTP', 'Yes', 'Yes 2', 'InMemoryOLTP','Applies to SQL Server 2016 (13.x) SP1 as part of creating a Common Programmability Surface Area (CPSA) across editions. Aggregate Pushdown, String Predicate Pushdown, and SIMD Optimizations are SQL Server Enterprise Edition scalability enhancements. For more detail, see Columnstore indexes - what''s new.'),
('Table and index partitioning', 'Yes', 'Yes 2', 'Partitioning','Applies to SQL Server 2016 (13.x) SP1 as part of creating a Common Programmability Surface Area (CPSA) across editions. Aggregate Pushdown, String Predicate Pushdown, and SIMD Optimizations are SQL Server Enterprise Edition scalability enhancements. For more detail, see Columnstore indexes - what''s new.'),
('Transparent database encryption', 'Yes', 'No', 'TransparentDataEncryption','')



SELECT CONCAT(type_desc,': ', CAST(COUNT(*) as VARCHAR)) as object_count
FROM sys.objects
WHERE is_ms_shipped = 0
GROUP BY type_desc
ORDER BY object_count;

GO
