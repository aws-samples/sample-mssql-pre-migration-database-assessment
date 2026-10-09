# server_linked_server_information

### Description

This table contains information about linked servers configured on SQL Server instances.

### Schema

- raw

### Table Columns

| Column Name          | Data Type    | Description                             | Constraints         | Example Values           |
|----------------------|--------------|-----------------------------------------|----------------------|--------------------------|
| `SQLInstance`        | VARCHAR(50)  | SQL Server instance name                | NULL                 | ServerA                  |
| `LinkedServerName`   | VARCHAR(100) | Name of the linked server               | NULL                 | LinkedServer1            |
| `ProviderName`       | VARCHAR(100) | Provider name                           | NULL                 | SQLNCLI                  |
| `Product`            | VARCHAR(100) | Product name                            | NULL                 | SQL Server               |
| `DataSource`         | VARCHAR(100) | Data source name                        | NULL                 | RemoteServer1            |
| `RemoteName`         | VARCHAR(100) | Remote object name                      | NULL                 | RemoteDatabase1          |
| `ProviderString`     | VARCHAR(100) | Provider-specific connection information | NULL               | NULL                     |
| `Location`           | VARCHAR(100) | Location information                    | NULL                 | NULL                     |
| `category`           | VARCHAR(100) | Category of the linked server           | NULL                 | Database                 |
| `collect_date`       | DATETIME     | Date and time of data collection        | NULL                 | 2024-03-06 20:00:00      |

### Indexes

- `ix_server_linked_server_information_sql_instance`: Clustered index on the `SQLInstance` column for faster lookup of SQL Instances.


### Script

- [server_linked_server_information](../scripts/server_linked_server_information.md)
