# database_to_server_mapping

### Description

This table contains information about active sessions within a SQL Server instance, including session ID, connection time, client details, database information, network protocol, encryption settings, authentication scheme, and the timestamp indicating when the data was collected.

### Schema

- raw

### Table Columns

| Column Name                  | Data Type     | Description                                      | Constraints  | Example Values           |
|------------------------------|---------------|--------------------------------------------------|--------------|--------------------------|
| `SQLInstance`                | NVARCHAR(128) | SQL Server instance name                         | NULL         | AOAG-NODE-1              |
| `session_id`                 | INT           | Identifier for the session                       | NULL         | 1                        |
| `connect_time`               | DATETIME      | Time when the connection was established         | NULL         | 2022-11-30 12:26:58.763  |
| `host_name`                  | NVARCHAR(128) | The hostname of the connecting client            | NULL         | ServerA                  |
| `program_name`               | NVARCHAR(128) | The name of the program connecting to the server | NULL         | ApplicationName          |
| `DatabaseName`               | NVARCHAR(128) | Name of the connected database                   | NULL         | AdventureWorks           |
| `AuthenticatingDatabaseName` | NVARCHAR(128) | Name of the database used for authentication     | NULL         | master                   |
| `login_name`                 | NVARCHAR(128) | The login name used for authentication           | NULL         | user1                    |
| `net_transport`              | NVARCHAR(128) | The network transport protocol being used        | NULL         | TCP                      |
| `protocol_type`              | NVARCHAR(128) | The protocol type                                | NULL         | TSQL                     |
| `encrypt_option`             | NVARCHAR(128) | Option for encryption                            | NULL         | TRUE                     |
| `auth_scheme`                | NVARCHAR(128) | Authentication scheme being used                 | NULL         | SQL                      |
| `date_collected`             | DATETIME      | Timestamp indicating when the data was collected | NULL         | 2022-12-13 14:47:48.110  |

### Indexes

- `ix_database_to_server_mapping_sql_instance`: Clustered index on the `SQLInstance`, column for faster lookup.

### Script

- [database_to_server_mapping](../scripts/database_to_server_mapping.md)
