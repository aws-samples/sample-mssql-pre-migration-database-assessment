# database_environment_settings_on_ssisdb

### Description

This table contains information about environment settings on the SSISDB database on SQL Server instances.

### Schema

- raw

### Table Columns

| Column Name        | Data Type     | Description                              | Constraints         | Example Values           |
|--------------------|---------------|------------------------------------------|----------------------|--------------------------|
| `SQLInstance`      | VARCHAR(50)   | SQL Server instance name                 | NULL                 | ServerA                  |
| `FolderName`       | NVARCHAR(100) | Name of the folder in SSISDB             | NULL                 | MyFolder                 |
| `EnvironmentName`  | NVARCHAR(50)  | Name of the environment                  | NULL                 | Production               |
| `VariableName`     | NVARCHAR(100) | Name of the environment variable         | NULL                 | ConnectionString         |
| `DataType`         | NVARCHAR(100) | Data type of the environment variable    | NULL                 | String                   |
| `Value`            | NVARCHAR(1024)| Value of the environment variable        | NULL                 | Data Source=ServerA;... |
| `CreatedByName`    | VARCHAR(100)  | Name of the user who created the setting | NULL                 | JohnDoe                  |
| `collect_date`     | DATETIME      | Date and time of data collection         | NULL                 | 2024-03-06 15:20:00      |

### Indexes

- `ix_database_environment_settings_on_ssisdb_sql_instance`: Clustered index on the `SQLInstance` column for faster lookup of SQL Instances.

### Script

- [database_environment_settings_on_ssisdb](../scripts/database_environment_settings_on_ssisdb.md)
