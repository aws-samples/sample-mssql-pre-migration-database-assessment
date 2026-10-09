# server_cpu_utilization.sql

### Description

Script to retrieve cpu utilization from the host for the last 4 hours

### Permissions needed

- VIEW SERVER STATE

### Scope

- Server

### Tables queried

- sys.dm_os_sys_info

#### Columns
- SQLInstance
- record_id
- EventTime
- system_cpu_utilization
- sql_cpu_utilization
- collect_date


### AwsDatabaseAssessment Table Name

- raw.server_cpu_utilization


### Sample Results

| SQLInstance  |  record_id | EventTime  | system_cpu_utilization  |  sql_cpu_utilization | collect_date |
|---|---|---|---|---|---|
|AOAG-NODE-1|4652|2023-03-09 16:24:38.317|3|25|2023-03-09 16:25:20.847|
|AOAG-NODE-1|4651|2023-03-09 16:23:38.183|2|25|2023-03-09 16:25:20.847|
|AOAG-NODE-1|4650|2023-03-09 16:22:38.063|2|26|2023-03-09 16:25:20.847|
|AOAG-NODE-1|4649|2023-03-09 16:21:39.963|6|33|2023-03-09 16:25:20.847|
|AOAG-NODE-1|4649|2023-03-09 16:21:40.963|9|32|2023-03-09 16:25:20.847|
|AOAG-NODE-1|4649|2023-03-09 16:21:41.963|14|45|2023-03-09 16:25:20.847|
