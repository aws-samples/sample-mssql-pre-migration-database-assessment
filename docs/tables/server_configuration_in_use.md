# server_configuration_in_use

### Description

This table contains information about the configuration settings (sp_configure) currently in use on SQL Server instances.

### Schema

- raw

### Table Columns

| Column Name          | Data Type     | Description                               | Constraints         | Example Values           |
|----------------------|---------------|-------------------------------------------|----------------------|--------------------------|
| `SQLInstance`        | VARCHAR(50)   | SQL Server instance name                  | NULL                 | ServerA                  |
| `ConfigurationName`  | NVARCHAR(128) | Name of the configuration setting         | NULL                 | Max Server Memory (MB)   |
| `State`              | VARCHAR(100)  | State of the configuration setting        | NULL                 | Configured                |
| `collect_date`       | DATETIME      | Date and time of data collection          | NULL                 | 2024-03-06 20:00:00      |

### Indexes

- `ix_server_configuration_in_use_sql_instance`: Clustered index on the `SQLInstance` column for faster lookup of SQL Instances.


### Script

- [server_configuration_in_use](../scripts/server_configuration_in_use.md)
