# server_deprecated_features.sql

### Description

Script provides a counter to monitor the features designated as deprecated. provides a usage count that lists the number of times the deprecated feature was encountered since SQL Server last started.

### Permissions needed

- VIEW SERVER STATE

### Scope

- Server

### Tables queried

- sys.dm_os_performance_counters

#### Columns
- SQLInstance
- DeprecatedFeature
- UsageCount
- collect_date


### AwsDatabaseAssessment Table Name

- raw.server_deprecated_features


### Sample Results

| SQLInstance  |  DeprecatedFeature | UsageCount | collect_date |
|---|---|---|---|
|AOAG-NODE-1|String literals as column aliases|91|2022-12-07 13:01:55.997|
|AOAG-NODE-1|INSERT NULL into TIMESTAMP columns|2|2022-12-07 13:01:55.997|
|AOAG-NODE-1|Multiple table hints without comma|2|2022-12-07 13:01:55.997|
|AOAG-NODE-1|sysdatabases|26|2022-12-07 13:01:55.997|
|AOAG-NODE-1|XP_API|7|2022-12-07 13:01:55.997|
