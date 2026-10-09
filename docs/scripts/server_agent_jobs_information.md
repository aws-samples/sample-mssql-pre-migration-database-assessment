# server_agent_jobs_information.sql

### Description

Script to retrieve the list of jobs

### Permissions needed

- db_datareader on msdb database

### Scope

- Server

### Tables queried

- dbo.sysjobs
- dbo.syscategories
- dbo.sysjobsteps

#### Columns
- SQLInstance
- JobName
- enabled
- description
- JobOwner
- JobCategoryName
- step_id
- step_name
- subsystem
- database_name
- command
- On_Success
- On_Failure
- notify_level_eventlog
- notify_level_email
- notify_email_operator_id
- delete_level
- collect_date


### AwsDatabaseAssessment Table Name

- raw.server_agent_jobs_information


### Sample Results

| SQLInstance  |  JobName | enabled  | description  |  JobOwner | JobCategoryName | step_id | step_name | subsystem | database_name | command | On_Success | On_Failure | notify_level_eventlog | notify_level_email | notify_email_operator_id | delete_level | collect_date|
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
AOAG-NODE-1|[DBAMaint] - Weekly Database Maintenance|	1|	Master SQL Server Agent Job responsible for triggering the SQL Agent Jobs in following order. 1) IndexOptimize - USER_DATABASES                                               2) UpdateStatistics - USER_DATABASES 3) DatabaseIntegrityCheck - USER_DATABASES|	CORP\Admin|	Database Maintenance|	1|	Trigger IndexOptimize - USER_DATABASES|	TSQL|	DBAMaint|	EXECUTE dbo.IndexOptimize   @Databases = 'USER_DATABASES, -rdsadmin,-rdsadmin_ReportServer,-rdsadmin_ReportServer,-rdsadmin_ReportServerTempDB,-SSISDB',  @FragmentationLow = NULL,  @FragmentationMedium = 'INDEX_REORGANIZE,INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE',  @FragmentationHigh = 'INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE',  @FragmentationLevel1 = 5,  @FragmentationLevel2 = 30,  @SortInTempdb = 'Y',  @MaxDOP = 0,  @LogToTable = 'Y',  @DatabasesInParallel = 'Y'|	Go to next step|	Quit with failure|	2|	0|	0|	0	|2022-12-13 16:23:24.240|
