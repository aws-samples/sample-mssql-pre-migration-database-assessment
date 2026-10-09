# database_msdb_ssis_packages

### Description

This table contains information about SSIS packages stored in the MSDB database on SQL Server instances.

### Schema

- raw

### Table Columns

| Column Name    | Data Type   | Description                      | Constraints | Example Values          |
|----------------|-------------|----------------------------------|-------------|-------------------------|
| `SQLInstance`  | VARCHAR(50) | SQL Server instance name         | NULL        | ServerA                 |
| `RootFolder`   | NVARCHAR(100)| Root folder of the SSIS package | NULL        | SSIS                    |
| `FullPath`     | NVARCHAR(500)| Full path of the SSIS package   | NULL        | \MSDB\SSIS_Packages     |
| `PackageName`  | NVARCHAR(100)| Name of the SSIS package        | NULL        | DataTransformation.dtsx |
| `Description`  | NVARCHAR(512)| Description of the SSIS package | NULL        | Package for data transfer|
| `collect_date` | DATETIME    | Date and time of data collection | NULL        | 2024-03-05 11:00:00     |

### Indexes

- `ix_database_msdb_ssis_packages_sql_instance`: Clustered index on the `SQLInstance` column for faster lookup of SQL Instances.

### Script

- [database_msdb_ssis_packages](../scripts/database_msdb_ssis_packages.md)
