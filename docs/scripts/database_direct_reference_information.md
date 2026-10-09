# database_direct_reference_information.sql

### Description

- Script to identify three and four part names in SQL Server code


### Permissions needed
- VIEW DATABASE DEFINITION
- db_owner on the databases

### Scope

- Database

### Tables queried

- sys.sql_expression_dependencies
- sys.objects

#### Columns
- SQLInstance
- referencing_database_name
- referencing_schema_name
- referencing_object_name
- referencing_object_type
- referenced_database_location
- referenced_server_name
- referenced_database_name
- referenced_schema_name
- referenced_object_name
- collect_date


### AwsDatabaseAssessment Table Name

- raw.database_direct_reference_information


### Sample Results

| SQLInstance  |  referencing_database_name | referencing_schema_name | referencing_object_name  | referencing_object_type  |  referenced_database_location | referenced_server_name | referenced_database_name | referenced_schema_name | referenced_object_name | collect_date |
|---|---|---|---|---|---|---|---|---|---|---|
|AOAG-NODE-1|AdventureWorks2016|dbo|uspGetManagerEmployees|SQL_STORED_PROCEDURE|External|localserver|EMP_cte|OrganizationNode|ToString|2022-12-07 13:10:27.753|
|AOAG-NODE-1|AdventureWorks2016|HumanResources|vJobCandidate|VIEW|External|localserver|Resume|ref|value|2022-12-07 13:10:27.753|
|AOAG-NODE-1|DBAMaint|dbo|DatabaseBackup|SQL_STORED_PROCEDURE|External|localserver|msdb|dbo|backupset|2022-12-07 13:10:27.753|
