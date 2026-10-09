# server_connections_by_ip_address.sql

### Description

Get a count of SQL connections by IP address

### Permissions needed

- VIEW DATABASE STATE

### Scope

- Server

### Tables queried

- sys.dm_exec_sessions
- sys.dm_exec_connections

#### Columns
- SQLInstance
- ClientAddress
- ProgramName
- HostName
- LoginName
- ConnectionCount
- collect_date


### AwsDatabaseAssessment Table Name

- raw.server_connections_by_ip_address


### Sample Results

| SQLInstance  |  ClientAddress | ProgramName  | HostName  |  LoginName | ConnectionCount | collect_date |
|---|---|---|---|---|---|---|
|AOAG-NODE-1|`<local machine>`|Microsoft SQL Server|AOAG-NODE-1|NT SERVICE\SQLSERVERAGENT|2|1|2022-12-07 12:58:32.043|
|AOAG-NODE-1|`<local machine>`|SQLAgent - Email Logger|DatabAOAG-NODE-1|NT AUTHORITY\SYSTEM|5|1|2022-12-07 12:58:32.043|
|AOAG-NODE-1|10.0.1.105|Microsoft SQL Server Management Studio|BASTION|CORP\Admin|1|2022-12-07 13:01:55.997|
