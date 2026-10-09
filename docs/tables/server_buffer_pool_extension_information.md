# server_buffer_pool_extension_information

### Description

This table contains information about buffer pool extension files on SQL Server instances.

### Schema

- raw

### Table Columns

| Column Name          | Data Type     | Description                               | Constraints         | Example Values           |
|----------------------|---------------|-------------------------------------------|----------------------|--------------------------|
| `SQLInstance`        | VARCHAR(50)   | SQL Server instance name                  | NULL                 | ServerA                  |
| `path`               | NVARCHAR(256) | Path of the buffer pool extension file    | NULL                 | C:\BufferExtension       |
| `file_id`            | INT           | ID of the buffer pool extension file      | NULL                 | 1                        |
| `state`              | INT           | State of the buffer pool extension file   | NULL                 | 0                        |
| `state_description`  | NVARCHAR(60)  | Description of the state                  | NOT NULL             | ONLINE                   |
| `current_size_in_kb` | BIGINT        | Current size of the extension file in KB  | NULL                 | 1048576                  |
| `collect_date`       | DATETIME      | Date and time of data collection          | NULL                 | 2024-03-06 20:00:00      |

### Indexes

- `ix_server_buffer_pool_extension_information_sql_instance`: Clustered index on the `SQLInstance` column for faster lookup of SQL Instances.


### Script

- [server_buffer_pool_extension_information](../scripts/server_buffer_pool_extension_information.md)
