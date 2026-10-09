# database_environment_settings_on_ssisdb.sql

### Description

Script to identify environment variables created on the SSISDB

### Permissions needed
- db_datareader on SSISDB

### Scope

- Database

### Tables queried

- catalog.environments
- catalog.folders
- catalog.environment_variables

#### Columns
- SQLInstance
- FolderName
- EnvironmentName
- VariableName
- DataType
- Value
- CreatedByName
- collect_date


### AwsDatabaseAssessment Table Name

- raw.database_environment_settings_on_ssisdb


### Sample Results

| SQLInstance  |  FolderName | EnvironmentName  | VariableName  |  DataType | Value | CreatedByName | collect_date |
|---|---|---|---|---|---|---|---|
|AOAG-NODE-1|ETL|PROD|SQLInstance|String|database-2.contoso.com|CORP\sqladmin|2022-12-07 13:57:30.897|
|AOAG-NODE-1|ETL|PROD|TargetSQLInstance|String|database-1.contoso.com|CORP\sqladmin|2022-12-07 13:57:30.897|
