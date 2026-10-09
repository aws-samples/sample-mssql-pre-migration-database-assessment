# server_cluster_information.sql

### Description

Script to check if Server is in Windows Server Failover Cluster (WSFC), if so, it returns the cluster nodes.

### Permissions needed

- VIEW SERVER STATE

### Scope

- Server

### Tables queried

- sys.dm_os_cluster_nodes

#### Columns
- SQLInstance
- NodeName
- status
- status_description
- is_current_owner
- collect_date


### AwsDatabaseAssessment Table Name

- raw.server_cluster_information


### Sample Results

| SQLInstance  |  NodeName | status  | status_description  |  is_current_owner | collect_date |
|---|---|---|---|---|---|
|AOAG-NODE-1|AOAG-NODE-1|1|up|1|2022-12-07 13:01:55.997|
|AOAG-NODE-1|AOAG-NODE-2|0|down|0|2022-12-07 13:01:55.997|
