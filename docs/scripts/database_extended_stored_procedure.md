# database_extended_stored_procedure.sql

### Description

Script to that tries to validate whether Stored Procedures are using Extended Stored Procedures, which is a blocker for RDS for SQL Server

### Permissions needed

- VIEW DATABASE STATE

### Scope

 - Database

### Tables queried

- sys.sql_modules

#### Columns

- SQLInstance
- DatabaseName
- ProcedureName
- Code
- collect_date


### AwsDatabaseAssessment Table Name

- raw.database_extended_stored_procedure


### Sample Results

| SQLInstance  |  DatabaseName | ProcedureName  | Code  |  collect_date |
|---|---|---|---|---|
|AOAG-NODE-1|AdventureWorks2016|TestExtendedStoredProcUsage|xp_cmdshell 'dir c:\'|2022-12-07 14:09:15.833|
|AOAG-NODE-1|AdventureWorks2016|TestExtendedStoredProcUsage|xp_regread 'HKEY_LOCAL_MACHINE', 'SOFTWARE\Microsoft\Windows\CurrentVersion', 'ProductName', @RegValue OUTPUT|2022-12-07 14:09:15.833|
