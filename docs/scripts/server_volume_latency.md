# server_volume_latency.sql

### Description

This SQL Server query retrieves performance information related to disk I/O latency for database files. It calculates various metrics such as read latency, write latency, overall latency, average bytes read, average bytes written, and average bytes transferred. The results provide insights into the I/O performance of the database files and the associated drives.

### Permissions needed

- VIEW SERVER STATE
- VIEW ANY DEFINITION

### Scope

- Server

### Tables queried

- sys.dm_io_virtual_file_stats
- sys.master_files
- sys.dm_os_volume_stats

#### Columns
- SQLInstance
- Drive
- VolumeMountPoint
- ReadLatency
- WriteLatency
- OverallLatency
- AvgBytesRead
- AvgBytesWrite
- AvgBytesTransfer
- collect_date


### AwsDatabaseAssessment Table Name

- raw.server_volume_latency


### Sample Results

| SQLInstance | Drive | VolumeMountPoint | ReadLatency | WriteLatency | OverallLatency | AvgBytesRead | AvgBytesWrite | AvgBytesTransfer | collect_date |
|------------|-------|------------------|------------|-------------|---------------|-------------|--------------|-----------------|---------------------|
| Server1    | C:     | C:\              | 5.42       | 2.13        | 3.83          | 8192        | 4096         | 6144            | 2023-11-07 10:30:00|
| Server1    | D:     | D:\              | 0.89       | 1.45        | 1.17          | 10240       | 8192         | 9216            | 2023-11-07 10:31:00|
| Server1    | E:     | E:\              | 2.75       | 0.67        | 1.88          | 6144        | 2048         | 4096            | 2023-11-07 10:32:00|
