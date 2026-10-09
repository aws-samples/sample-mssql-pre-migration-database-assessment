# database_ssisdb_ssis_packages.sql

### Description

Script to get ssis packages in SSISDB

### Permissions needed

- db_datareader on SSISDB database

### Scope

- Database

### Tables queried

- catalog.packages
- catalog.projects
- catalog.folders

#### Columns
- SQLInstance
- FolderName
- ProjectName
- PackageName
- Description
- DeployedBy
- LastDeploymentTime
- CreatedTime
- collect_date


### AwsDatabaseAssessment Table Name

- raw.database_ssisdb_ssis_packages


### Sample Results

| SQLInstance  |  FolderName | ProjectName  | PackageName  |  Description | DeployedBy | LastDeploymentTime | CreatedTime | collect_date |
|---|---|---|---|---|---|---|---|---|
|AOAG-NODE-1|ETL|ETL|Package.dtsx||CORP\Admin|2022-06-11 18:33:12.3802617 +00:00|2022-06-11 18:33:09.9901956 +00:00|2022-12-13 11:02:22.637|
