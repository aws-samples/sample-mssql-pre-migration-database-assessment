# ssis_packages_connection_type_ssisdb

### Description

This table stores information about the connection types used in SSIS packages in the SSISDB catalog on SQL Server instances.

### Schema

- raw

### Table Columns

| Column Name      | Data Type   | Description                              | Constraints  | Example Values         |
|------------------|-------------|------------------------------------------|--------------|------------------------|
| `SQLInstance`    | VARCHAR(50) | SQL Server instance name                  | NULL        | ServerA                |
| `ProjectName`    | VARCHAR(100)| Name of the SSIS project                 | NULL         | AdventureWorks         |
| `PackageName`    | VARCHAR(128)| Name of the SSIS package                 | NULL         | DataTransformation.dtsx|
| `ConnectionType` | VARCHAR(256)| Type of connection used in the package   | NULL         | OLEDB                  |
| `collect_date`   | DATETIME    | Date and time of data collection         | NULL         | 2024-03-05 11:30:00    |

### Indexes

- `ix_ssis_packages_connection_type_ssisdb_sql_instance`: Clustered index on the `SQLInstance` column for faster lookup of SQL Instances.


### Script

- [ssis_packages_connection_type_msdb](../scripts/ssis_packages_connection_type_ssisdb.md)
