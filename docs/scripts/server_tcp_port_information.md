# server_tcp_port_information.sql

### Description

This SQL Server script retrieves information about active network connections to the SQL Server instance. It provides details about network transport, protocol type, encryption options, authentication schemes, client network addresses, and local TCP ports. The results can be used to monitor and analyze network connections to the SQL Server.

### Permissions needed

- VIEW SERVER STATE

### Scope

- Server

### Tables queried

- sys.dm_exec_connections

#### Columns

- SQLInstance
- net_transport
- protocol_type
- encrypt_option
- auth_scheme
- client_net_address
- local_tcp_port
- collect_date


### AwsDatabaseAssessment Table Name

- raw.server_tcp_port_information


### Sample Results

| SQLInstance | net_transport | protocol_type | encrypt_option | auth_scheme | client_net_address | local_tcp_port | collect_date   |
|------------|--------------|---------------|----------------|------------|-------------------|---------------|---------------------|
| Server1    | TCP          | TSQL          | FALSE          | NTLM   | 192.168.1.100      | 1433          | 2023-11-07 10:30:00|
| Server1    | TCP          | TSQL          | TRUE           | SQL    | 192.168.1.101      | 1433          | 2023-11-07 10:31:00|
| Server1    | TCP          | TSQL          | TRUE           | SQL    | 192.168.1.102      | 1450          | 2023-11-07 10:32:00|
