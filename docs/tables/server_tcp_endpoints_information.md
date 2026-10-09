# server_tcp_endpoints_information

### Description

This table stores information about TCP endpoints configured on SQL Server instances.

### Schema

- raw

### Table Columns

| Column Name       | Data Type      | Description                                | Constraints         | Example Values        |
|-------------------|----------------|--------------------------------------------|----------------------|-----------------------|
| `SQLInstance`     | VARCHAR(50)    | SQL Server instance name                   | NULL                 | ServerA               |
| `EndpointName`    | SYSNAME        | Name of the TCP endpoint                   | NOT NULL             | TCP_Endpoint1         |
| `protocol_desc`   | NVARCHAR(60)   | Description of the protocol used           | NULL                 | TCP                   |
| `type_desc`       | VARCHAR(60)    | Description of the endpoint type           | NULL                 | Database Mirroring    |
| `collect_date`    | DATETIME       | Date and time of data collection           | NULL                 | 2024-03-06 20:00:00   |

### Indexes

- `ix_server_tcp_endpoints_information_sql_instance`: Clustered index on the `SQLInstance` column for faster lookup of SQL Instances.


### Script

- [server_tcp_endpoints_information](../scripts/server_tcp_endpoints_information.md)
