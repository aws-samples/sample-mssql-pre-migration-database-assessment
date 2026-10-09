# database_msdb_ssis_packages.sql

### Description

Script to get ssis packages in MSDB

### Permissions needed
- db_datareader on msdb

### Scope
- Database

### Tables queried

- dbo.sysssispackagefolders
- dbo.sysssispackages

#### Columns
- SQLInstance
- RootFolder
- FullPath
- PackageName
- Description
- collect_date


### AwsDatabaseAssessment Table Name

- raw.database_msdb_ssis_packages


### Sample Results

| SQLInstance  |  RootFolder | FullPath  | PackageName  |  Description | collect_date |
|---|---|---|---|---|---|
|AOAG-NODE-1|||Package||2022-12-12 12:22:59.510|
|AOAG-NODE-1|ETL|/ETL|LoadDelta||2022-12-12 12:22:59.510|
