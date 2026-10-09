# database_size_information.sql

### Description

Script to retrieve file sizes for individual database.

### Permissions needed

- Requires membership in the public role

### Scope

- Database

### Tables queried

- sys.database_files
- sys.filegroups

#### Columns

- SQLInstance
- DatabaseName
- FileName
- PhysicalName
- FileType
- FilegroupType
- TotalSizeinMB
- AvailableSpaceInMB
- UsedSpaceinMB
- collect_date


### AwsDatabaseAssessment Table Name

- raw.database_size_information


### Sample Results

| SQLInstance  |  DatabaseName | FileName  | PhysicalName  | FileType | FilegroupType |  TotalSizeinMB | AvailableSpaceInMB | UsedSpaceinMB | collect_date |
|---|---|---|---|---|---|---|---|---|---|
|AOAG-NODE-1|AdventureWorks2016|AdventureWorks2016_Data|D:\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Data\AdventureWorks2016_Data.mdf|ROWS|ROWS_FILEGROUP|207.63|1.94|205.69|2022-12-13 10:55:10.073|
|AOAG-NODE-1|AdventureWorks2016|AdventureWorks2016_Log|L:\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Log\AdventureWorks2016_Log.ldf|LOG|N/A|18.00|8.28|9.72|2022-12-13 10:55:10.073|
