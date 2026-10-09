# server_timezone_information

### Description

This table holds information about the timezone configuration on SQL Server instances.

### Schema

- raw

### Table Columns

| Column Name            | Data Type    | Description                                | Constraints         | Example Values          |
|------------------------|--------------|--------------------------------------------|----------------------|-------------------------|
| `SQLInstance`          | VARCHAR(50)  | SQL Server instance name                    | NULL                 | ServerA                 |
| `TimezoneConfiguration`| NVARCHAR(50) | Timezone configuration of the SQL Server    | NULL                 | (UTC+08:00) Taipei     |
| `collect_date`         | DATETIME     | Date and time of data collection            | NULL                 | 2024-03-05 16:30:00     |

### Indexes

- `ix_server_timezone_information_sql_instance`: Clustered index on the `SQLInstance` column for faster lookup of SQL Instances.

### Script

- [server_timezone_information](../scripts/server_timezone_information.md)
