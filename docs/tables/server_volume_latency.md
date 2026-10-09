# server_volume_latency

### Description

This table stores information about volume latency on SQL Server instances.

### Schema

- raw

### Table Columns

| Column Name         | Data Type   | Description                                     | Constraints                   | Example Values   |
|---------------------|-------------|-------------------------------------------------|-------------------------------|------------------|
| `SQLInstance`       | VARCHAR(50) | SQL Server instance name                                  | NULL                | ServerA          |
| `Drive`             | NVARCHAR(5) | Drive letter of the volume                                | NULL                | C                |
| `VolumeMountPoint`  | NVARCHAR(5) | Mount point of the volume                                 | NULL                | C:\              |
| `ReadLatency`       | INT         | Read latency in milliseconds                              | NULL                | 10               |
| `WriteLatency`      | INT         | Write latency in milliseconds                             | NULL                | 5                |
| `OverallLatency`    | INT         | Overall (combined read and write) latency in milliseconds | NULL                | 15               |
| `AvgBytesRead`      | INT         | Average bytes read per operation                          | NULL                | 1024             |
| `AvgBytesWrite`     | INT         | Average bytes written per operation                       | NULL                | 512              |
| `AvgBytesTransfer`  | INT         | Average bytes transferred per operation                   | NULL                | 1536             |
| `collect_date`      | DATETIME    | Date and time of data collection                          | NULL                | 2024-03-06 20:00:00 |

### Indexes

- `ix_server_volume_latency_sql_instance`: Clustered index on the `SQLInstance` column for faster lookup of SQL Instances.


### Script

- [server_volume_latency](../scripts/server_volume_latency.md)
