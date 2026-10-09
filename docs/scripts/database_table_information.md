# database_table_information.sql

### Description

Script to retrieve list of tables for a database

### Permissions needed

- The visibility of the metadata in catalog views is limited to securables that a user either owns or on which the user has been granted some permission.

### Scope

- Database

### Tables queried

- sys.objects
- sys.schemas

#### Columns
- SQLInstance
- DatabaseName
- SchemaName
- TableName
- collect_date


### AwsDatabaseAssessment Table Name

- raw.database_table_information


### Sample Results

| SQLInstance  |  DatabaseName | SchemaName  | TableName  |  collect_date |
|---|---|---|---|---|
AOAG-NODE-1	|ReportServer|	dbo|	DBUpgradeHistory|	2022-12-13 14:44:24.667|
AOAG-NODE-1|	ReportServer|	dbo|	DataSets|	2022-12-13 14:44:24.667|
