# server_db_snapshot_information.sql

### Description

Script to check if instance has Snapshot database

### Permissions needed

- VIEW SERVER STATE

### Scope

- Server

### Tables queried

- sys.databases

#### Columns
- SQLInstance
- SnapshotDatabaseName
- SourceDatabaseName
- create_date
- collect_date


### AwsDatabaseAssessment Table Name

- raw.server_db_snapshot_information


### Sample Results

| SQLInstance  |  SnapshotDatabaseName | SourceDatabaseName  | create_date  | collect_date |
|---|---|---|---|---|
|AOAG-NODE-1|BikeStores_dbss1800|BikeStores|2023-03-13 10:47:51.490|2022-12-07 13:01:55.997|
