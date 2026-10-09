# server_cpu_utilization

### Description

This table contains information about CPU utilization on the SQL Server Instance and host. This helps to understand whether the host is suffering pressure from SQL Server, or any other component.

### Schema

- raw

### Table Columns

| Column Name              | Data Type   | Description                           | Constraints         | Example Values           |
|--------------------------|-------------|---------------------------------------|----------------------|--------------------------|
| `SQLInstance`            | VARCHAR(50) | SQL Server instance name              | NULL                 | ServerA                  |
| `record_id`              | INT         | Unique identifier for the record      | NULL                 | 1                        |
| `EventTime`              | DATETIME    | Date and time of the event            | NULL                 | 2024-03-06 08:00:00      |
| `system_cpu_utilization` | INT         | CPU utilization by the system (%)     | NULL                 | 10                       |
| `sql_cpu_utilization`    | INT         | CPU utilization by SQL Server (%)     | NULL                 | 20                       |
| `collect_date`           | DATETIME    | Date and time of data collection      | NULL                 | 2024-03-06 20:00:00      |

### Indexes

- `ix_server_cpu_utilization_sql_instance`: Clustered index on the `SQLInstance` column for faster lookup of SQL Instances.


### Script

- [server_cpu_utilization](../scripts/server_cpu_utilization.md)
