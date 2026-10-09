# database_to_server_mapping.sql

### Description

This T-SQL script retrieves detailed information about active sessions within a SQL Server instance, including session ID, connection time, client details, database information, network protocol, encryption settings, authentication scheme, and the timestamp indicating when the data was collected.

### Permissions needed

- ALTER ANY USER

### Scope

- Server

### Tables queried

- sys.dm_exec_connections
- sys.dm_exec_sessions
- sys.dm_exec_requests

#### Columns
- SQLInstance
- session_id
- connect_time
- host_name
- program_name
- DatabaseName
- AuthenticatingDatabaseName
- login_name
- net_transport
- protocol_type
- encrypt_option
- auth_scheme
- date_collected


### Raw Database Table Name

- raw_database_to_server_mapping


### Sample Results

| SQLInstance  |  session_id | connect_time  | host_name  |  program_name | DatabaseName | AuthenticatingDatabaseName | login_name | net_transport | protocol_type | encrypt_option | auth_scheme | date_collected |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
AOAG-NODE-1|1|2022-11-30 12:26:58.763|ServerName|ApplicationName|AdventureWorks|master|user1|TCP|TSQL|TRUE|SQL|2022-12-13 14:47:48.110|
