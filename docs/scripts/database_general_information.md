# database_general_information.sql

### Description

Script to collect database information from all (system + user) databases in the server

### Permissions needed
- VIEW ANY DATABASE
- VIEW SERVER STATE

### Scope
 - Database

### Tables queried

- sys.databases
- sys.dm_db_index_usage_stats

#### Columns
- SQLInstance
- DatabaseId
- DatabaseName
- CompatibilityLevel
- Owner
- CollationName
- UserAccess
- ReadOnlyDatabase
- DatabaseState
- RecoveryModel
- ReadCommittedSnapshotIsolation
- SnapshotIsolationState
- IsDistributorDatabase
- IsSubscriberDatabase
- IsPublishedDatabase
- StretchDatabaseEnabled
- last_user_seek
- last_user_scan
- last_user_lookup
- last_user_update
- collect_date


### AwsDatabaseAssessment Table Name

- raw.database_general_information


### Sample Results

| SQLInstance  |  DatabaseId | DatabaseName  | CompatibilityLevel  |  Owner | CollationName | UserAccess | ReadOnlyDatabase | DatabaseState | RecoveryModel| ReadCommittedSnapshotIsolation | SnapshotIsolationState | IsDistributorDatabase | IsSubscriberDatabase | IsPublishedDatabase | StretchDatabaseEnabled | last_user_seek | last_user_scan | last_user_lookup | last_user_update | collect_date|
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
|AOAG-NODE-1|1|master|150|sa|SQL_Latin1_General_CP1_CI_AS|MULTI_USER|0|ONLINE|SIMPLE|0|ON|0|0|0|0|NULL|NULL|NULL|NULL|2022-12-07 14:15:18.910
|AOAG-NODE-1|2|tempdb|150|sa|SQL_Latin1_General_CP1_CI_AS|MULTI_USER|0|ONLINE|SIMPLE|0|OFF|0|0|0|0|NULL|NULL|NULL|NULL|2022-12-07 14:15:18.910
|AOAG-NODE-1|3|model|150|sa|SQL_Latin1_General_CP1_CI_AS|MULTI_USER|0|ONLINE|FULL|0|OFF|0|0|0|0|NULL|NULL|NULL|NULL|2022-12-07 14:15:18.910
|AOAG-NODE-1|4|msdb|150|sa|SQL_Latin1_General_CP1_CI_AS|MULTI_USER|0|ONLINE|SIMPLE|0|ON|0|0|0|0|2022-12-07 14:14:00.490|2022-12-07 14:14:00.490|2022-12-07 14:08:38.660|2022-12-07 14:14:00.490|2022-12-07 14:15:18.910
