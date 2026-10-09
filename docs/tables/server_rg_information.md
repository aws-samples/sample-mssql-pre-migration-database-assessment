# server_rg_information

### Description

This table contains information about resource governor configuration on SQL Server instances.

### Schema

- raw

### Table Columns

| Column Name                     | Data Type     | Description                                          | Constraints         | Example Values       |
|---------------------------------|---------------|------------------------------------------------------|----------------------|----------------------|
| `SQLInstance`                   | VARCHAR(50)   | SQL Server instance name                             | NULL                 | ServerA              |
| `is_enabled`                    | BIT           | Indicates if Resource Governor is enabled             | NULL                 | 1 (Enabled), 0 (Disabled) |
| `classifier`                    | INT           | Classifier function ID                               | NULL                 | 1000                 |
| `pool_name`                     | NVARCHAR(128) | Name of the resource pool                            | NULL                 | Pool1                |
| `group_name`                    | NVARCHAR(128) | Name of the workload group                           | NULL                 | Group1               |
| `importance`                    | NVARCHAR(128) | Importance of the workload group                     | NULL                 | Low, Medium, High    |
| `request_max_memory_grant_percent`| INT        | Maximum memory grant percentage for requests         | NULL                 | 50                   |
| `request_max_cpu_time_sec`      | INT           | Maximum CPU time for requests in seconds             | NULL                 | 60                   |
| `min_memory_percent`            | INT           | Minimum memory percent allocated to the pool         | NULL                 | 10                   |
| `max_memory_percent`            | INT           | Maximum memory percent allocated to the pool         | NULL                 | 90                   |
| `min_cpu_percent`               | INT           | Minimum CPU percent allocated to the pool            | NULL                 | 10                   |
| `max_cpu_percent`               | INT           | Maximum CPU percent allocated to the pool            | NULL                 | 90                   |
| `collect_date`                  | DATETIME      | Date and time of data collection                     | NULL                 | 2024-03-06 20:00:00  |

### Indexes

- `ix_server_rg_information_sql_instance`: Clustered index on the `SQLInstance` column for faster lookup of SQL Instances.


### Script

- [server_rg_information](../scripts/server_rg_information.md)
