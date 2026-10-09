# database_ssisdb_ssis_packages

### Description

This table contains information about SSIS packages stored in the SSISDB catalog on SQL Server instances.

### Schema

- raw

### Table Columns

| Column Name          | Data Type    | Description                               | Constraints | Example Values           |
|----------------------|--------------|-------------------------------------------|-------------|--------------------------|
| `SQLInstance`        | VARCHAR(50)  | SQL Server instance name                  | NULL        | ServerA                  |
| `FolderName`         | VARCHAR(128) | Name of the folder containing the package | NULL        | SSIS_Packages            |
| `ProjectName`        | VARCHAR(128) | Name of the SSIS project                  | NULL        | AdventureWorks           |
| `PackageName`        | VARCHAR(128) | Name of the SSIS package                  | NULL        | DataTransformation.dtsx  |
| `Description`        | VARCHAR(256) | Description of the SSIS package           | NULL        | Package for data transfer|
| `DeployedBy`         | VARCHAR(50)  | Name of the user who deployed the package | NULL        | JohnDoe                  |
| `LastDeploymentTime` | DATETIME     | Date and time of last deployment          | NULL        | 2024-03-05 12:30:00      |
| `CreatedTime`        | VARCHAR(50)  | Date and time of package creation         | NULL        | 2024-03-01 09:00:00      |
| `collect_date`       | DATETIME     | Date and time of data collection          | NULL        | 2024-03-05 13:00:00      |

### Indexes

- `ix_database_ssisdb_ssis_packages_sql_instance`: Clustered index on the `SQLInstance` column for faster lookup of SQL Instances.

### Script

- [database_ssisdb_ssis_packages](../scripts/database_ssisdb_ssis_packages.md)
