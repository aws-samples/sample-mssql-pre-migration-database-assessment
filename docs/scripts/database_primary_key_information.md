# database_primary_key_information.sql

### Description

Script to collect primary key information

### Permissions needed

- public permission on the databases

### Scope

- Database

### Tables queried

- sys.tables
- sys.indexes

#### Columns
- SQLInstance
- DatabaseName
- SchemaName
- TableName
- collect_date


### AwsDatabaseAssessment Table Name

- raw.database_primary_key_information


### Sample Results

| SQLInstance  |  DatabaseName | SchemaName  | TableName  |  collect_date |
|---|---|---|---|---|
|AOAG-NODE-1|AwsDatabaseAssessment|dbo|default_sp_configure|2022-12-07 13:01:55.997|
|AOAG-NODE-1|AwsDatabaseAssessment|raw|database_io_utilization|2022-12-07 13:01:55.997|
