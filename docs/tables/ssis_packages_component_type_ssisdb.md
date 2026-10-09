# ssis_packages_component_type_ssisdb

### Description

This table stores information about the component types used in SSIS packages in the SSISDB catalog on SQL Server instances.

### Schema

- raw

### Table Columns

| Column Name      | Data Type   | Description                               | Constraints   | Example Values          |
|------------------|-------------|-------------------------------------------|---------------|-------------------------|
| `SQLInstance`    | VARCHAR(50) | SQL Server instance name                  | NULL          | ServerA                 |
| `ProjectName`    | VARCHAR(100)| Name of the SSIS project                  | NULL          | AdventureWorks          |
| `PackageName`    | VARCHAR(128)| Name of the SSIS package                  | NULL          | DataTransformation.dtsx |
| `ComponentType`  | VARCHAR(256)| Type of SSIS component used in the package| NULL          | Data Flow Task          |
| `collect_date`   | DATETIME    | Date and time of data collection          | NULL          | 2024-03-05 12:00:00     |

### Indexes

- `ix_ssis_packages_component_type_ssisdb_sql_instance`: Clustered index on the `SQLInstance` column for faster lookup of SQL Instances.

### Script

- [ssis_packages_component_type_ssisdb](../scripts/ssis_packages_component_type_ssisdb.md)
