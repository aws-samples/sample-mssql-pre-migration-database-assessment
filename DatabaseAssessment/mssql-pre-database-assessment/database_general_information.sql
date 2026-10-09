/*
#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

*/

/*
Author: 		Marcos Freccia (mfreccia)
Date: 			29/11/2022
Description: 	Script to collect all databases from the SQL Instance and last database utilization
Permission:     VIEW ANY DATABASE, VIEW SERVER STATE
*/


DECLARE @SQLBuild INT = 0,
        @STRSQL VARCHAR(MAX);
SELECT @SQLBuild
    = SUBSTRING(
                   CAST(SERVERPROPERTY('productversion') AS VARCHAR),
                   0,
                   CHARINDEX('.', CAST(SERVERPROPERTY('productversion') AS VARCHAR))
               );
IF (@SQLBuild) > 12
BEGIN
    SET @STRSQL
        = 'SELECT @@SERVERNAME as SQLInstance,
	   db.database_id AS DatabaseID,
       name AS DatabaseName,
       compatibility_level AS CompatibilityLevel,
       ISNULL(SUSER_NAME(owner_sid),''N/A'') AS Owner,
       collation_name AS CollationName,
       user_access_desc AS UserAccess,
       is_read_only AS ReadOnlyDatabase,
       state_desc AS DatabaseState,
       recovery_model_desc AS RecoveryModel,
       is_read_committed_snapshot_on ReadCommittedSnapshotIsolation,
       snapshot_isolation_state_desc SnapshotIsolationState,
       is_distributor  IsDistributorDatabase,
	   is_subscribed IsSubscriberDatabase,
       is_published IsPublishedDatabase,
       is_remote_data_archive_enabled StretchDatabaseEnabled,
	    last_user_seek = ISNULL(MAX(last_user_seek),''1900-01-01''),
		last_user_scan = ISNULL(MAX(last_user_scan),''1900-01-01''),
		last_user_lookup = ISNULL(MAX(last_user_lookup),''1900-01-01''),
		last_user_update = ISNULL(MAX(last_user_update),''1900-01-01''),
		GETDATE() as collect_date
	   FROM sys.databases (NOLOCK) as db
	   LEFT JOIN sys.dm_db_index_usage_stats (NOLOCK) AS i
		ON i.database_id=db.database_id
		GROUP BY SUSER_NAME(owner_sid),
                 db.database_id,
                 db.name,
                 db.compatibility_level,
                 db.collation_name,
                 db.user_access_desc,
                 db.is_read_only,
                 db.state_desc,
                 db.recovery_model_desc,
                 db.is_read_committed_snapshot_on,
                 db.snapshot_isolation_state_desc,
                 db.is_distributor,
                 db.is_subscribed,
                 db.is_published,
				 is_remote_data_archive_enabled
		ORDER BY db.database_id				 ';
    EXEC (@STRSQL);
END;
ELSE
BEGIN
    SET @STRSQL
        = 'SELECT @@SERVERNAME as SQLInstance,
	   db.database_id AS DatabaseID,
       name AS DatabaseName,
       compatibility_level AS CompatibilityLevel,
       ISNULL(SUSER_NAME(owner_sid),''N/A'') AS Owner,
       collation_name AS CollationName,
       user_access_desc AS UserAccess,
       is_read_only AS ReadOnlyDatabase,
       state_desc AS DatabaseState,
       recovery_model_desc AS RecoveryModel,
       is_read_committed_snapshot_on ReadCommittedSnapshotIsolation,
       snapshot_isolation_state_desc SnapshotIsolationState,
       is_distributor  IsDistributorDatabase,
	   is_subscribed IsSubscriberDatabase,
       is_published IsPublishedDatabase,
       CAST(0 as bit) as StretchDatabaseEnabled,
	   last_user_seek = ISNULL(MAX(last_user_seek),''1900-01-01''),
	   last_user_scan = ISNULL(MAX(last_user_scan),''1900-01-01''),
		last_user_lookup = ISNULL(MAX(last_user_lookup),''1900-01-01''),
		last_user_update = ISNULL(MAX(last_user_update),''1900-01-01''),
		getdate() as collect_date
	   FROM sys.databases (NOLOCK) as db
	   LEFT JOIN sys.dm_db_index_usage_stats (NOLOCK) AS i
		ON i.database_id=db.database_id
		GROUP BY SUSER_NAME(owner_sid),
                 db.database_id,
                 db.name,
                 db.compatibility_level,
                 db.collation_name,
                 db.user_access_desc,
                 db.is_read_only,
                 db.state_desc,
                 db.recovery_model_desc,
                 db.is_read_committed_snapshot_on,
                 db.snapshot_isolation_state_desc,
                 db.is_distributor,
                 db.is_subscribed,
                 db.is_published
		ORDER BY db.database_id';
    EXEC (@STRSQL);
END;
