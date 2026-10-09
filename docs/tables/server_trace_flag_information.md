# server_trace_flag_information

### Description

This table stores information about trace flags configured on SQL Server instances.

### Schema

- raw

### Table Columns

| Column Name       | Data Type   | Description                                   | Constraints         | Example Values   |
|-------------------|-------------|-----------------------------------------------|---------------------|------------------|
| `SQLInstance`     | VARCHAR(50) | SQL Server instance name                      | NULL                | ServerA          |
| `TraceFlag`       | INT         | Trace flag number                             | NULL                | 3604             |
| `Status`          | INT         | Status of the trace flag                      | NULL                | 1                |
| `Global`          | INT         | Indicates if the trace flag is set globally  | NULL                | 1                |
| `Session`         | INT         | Indicates if the trace flag is set per session | NULL               | 0                |
| `collect_date`    | DATETIME    | Date and time of data collection              | NULL                | 2024-03-06 20:00:00 |

### Indexes

- `ix_server_trace_flag_information_sql_instance`: Clustered index on the `SQLInstance` column for faster lookup of SQL Instances.


### Script

- [server_trace_flag_information](../scripts/server_trace_flag_information.md)
