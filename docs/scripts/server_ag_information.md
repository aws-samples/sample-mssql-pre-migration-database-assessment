# server_ag_information.sql

### Description

Script to describe the SQL Server Availability Groups configuration

### Permissions needed

- VIEW SERVER STATE

### Scope

- Server

### Tables queried

- sys.dm_hadr_database_replica_states
- sys.availability_databases_cluster
- sys.availability_groups
- sys.availability_replicas
- sys.dm_hadr_availability_group_states
- sys.dm_hadr_availability_replica_states
- sys.availability_group_listeners
- sys.availability_group_listener_ip_addresses

#### Columns
- SQLInstance
- replica_server_name
- Listener
- Listener_port
- Listener_state
- database_name
- ag_name
- automated_backup_preference_desc
- role_desc
- synchronization_state_desc
- availability_mode_desc
- failover_mode_desc
- primary_role_allow_connections_desc
- secondary_role_allow_connections_desc
- is_commit_participant
- synchronization_health_desc
- last_commit_time
- collect_date


### AwsDatabaseAssessment Table Name

- raw.server_ag_information


### Sample Results

| SQLInstance  |  replica_server_name | Listener  | Listener_port  |  Listener_state | database_name | ag_name | automated_backup_preference_desc | role_desc | synchronization_state_desc |availability_mode_desc|failover_mode_desc|primary_role_allow_connections_desc|secondary_role_allow_connections_desc|is_commit_participant|synchronization_health_desc|last_commit_time|collect_date|
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
AOAG-NODE-1| AOAG-NODE-1| AOAGSQLLS00 |1433| ONLINE|	AdventureWorks2016|AOAGSQLAG00 |primary|PRIMARY|SYNCHRONIZED|	SYNCHRONOUS_COMMIT|AUTOMATIC|ALL|ALL|1|	HEALTHY| 2022-12-13 15:02:26.783|2022-12-13 15:07:31.783|
