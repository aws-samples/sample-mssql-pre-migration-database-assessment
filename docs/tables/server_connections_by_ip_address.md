# server_connections_by_ip_address

### Description

This table contains information about connections to SQL Server instances grouped by client IP address. This helps to understand which TCP ports are being used.

### Schema

- raw

### Table Columns

| Column Name        | Data Type       | Description                                | Constraints         | Example Values    |
|--------------------|-----------------|--------------------------------------------|---------------------|-------------------|
| `SQLInstance`      | VARCHAR(50)     | SQL Server instance name                   | NULL                | ServerA           |
| `ClientAddress`    | NVARCHAR(50)    | IP address of the client                   | NULL                | 192.168.1.100     |
| `ProgramName`      | NVARCHAR(128)   | Name of the program making the connection | NULL                | SQLCMD            |
| `HostName`         | NVARCHAR(50)    | Host name of the client                    | NULL                | ClientMachine     |
| `LoginName`        | NVARCHAR(50)    | Login name used for the connection         | NULL                | john_doe          |
| `ConnectionCount`  | INT             | Number of connections from this IP address | NULL                | 10                |
| `collect_date`     | DATETIME        | Date and time of data collection           | NULL                | 2024-03-06 20:00:00 |

### Indexes

- `ix_server_connections_by_ip_address_sql_instance`: Clustered index on the `SQLInstance` column for faster lookup of SQL Instances.


### Script

- [server_connections_by_ip_address](../scripts/server_connections_by_ip_address.md)
