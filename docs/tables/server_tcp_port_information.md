# server_tcp_port_information

### Description

This table stores information about TCP ports configured on SQL Server instances.

### Schema

- raw

### Table Columns

| Column Name          | Data Type      | Description                                | Constraints         | Example Values     |
|----------------------|----------------|--------------------------------------------|----------------------|----------------------|
| `SQLInstance`        | VARCHAR(50)    | SQL Server instance name                   | NULL                 | ServerA              |
| `net_transport`      | NVARCHAR(10)   | Network transport protocol used            | NULL                 | TCP                  |
| `protocol_type`      | NVARCHAR(10)   | Type of protocol                           | NULL                 | TSQL                 |
| `encrypt_option`     | NVARCHAR(10)   | Encryption option                          | NULL                 | ENABLED              |
| `auth_scheme`        | NVARCHAR(10)   | Authentication scheme                      | NULL                 | SQL                  |
| `client_net_address` | NVARCHAR(50)   | Client network address                     | NULL                 | 192.168.1.100        |
| `local_tcp_port`     | INT            | Local TCP port                             | NULL                 | 1433                 |
| `collect_date`       | DATETIME       | Date and time of data collection           | NULL                 | 2024-03-06 20:00:00  |

### Indexes

- `ix_server_tcp_port_information_sql_instance`: Clustered index on the `SQLInstance` column for faster lookup of SQL Instances.


### Script

- [server_tcp_port_information](../scripts/server_tcp_port_information.md)
