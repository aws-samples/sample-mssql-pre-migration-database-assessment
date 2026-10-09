# server_tcp_endpoints_information.sql

### Description

This SQL Server script retrieves information about network endpoints configured on the SQL Server instance. It provides details about endpoint names and their associated protocols. The results can be used to monitor and manage network endpoints for SQL Server.


### Permissions needed

- VIEW SERVER STATE

### Scope

- Server

### Tables queried

- sys.tcp_endpoints

#### Columns

- SQLInstance
- EndpointName
- protocol_desc
- collect_date

### AwsDatabaseAssessment Table Name

- raw.server_tcp_endpoints_information


### Sample Results

| SQLInstance | EndpointName           | protocol_desc | collect_date      |
|------------|------------------------|--------------|---------------------|
| Server1    | Default TCP            | TCP          | 2023-11-07 10:30:00|
| Server1    | NamedPipe              | NP           | 2023-11-07 10:31:00|
| Server1    | Default VIA            | VIA          | 2023-11-07 10:32:00|
