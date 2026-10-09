# server_ag_information

### Description

This table contains information about Always On Availability Groups (AG) on SQL Server instances.

### Schema

- raw

### Table Columns

| Column Name                           | Data Type       | Description                                   | Constraints         | Example Values           |
|---------------------------------------|-----------------|-----------------------------------------------|----------------------|--------------------------|
| `SQLInstance`                         | VARCHAR(50)     | SQL Server instance name                      | NULL                 | ServerA                  |
| `replica_server_name`                 | NVARCHAR(50)   | Name of the replica server                    | NULL                 | ReplicaServer1           |
| `Listener`                            | NVARCHAR(100)  | Name of the listener                          | NULL                 | AGListener               |
| `Listener_port`                       | INT             | Port of the listener                          | NULL                 | 1433                     |
| `Listener_state`                      | NVARCHAR(10)   | State of the listener                         | NULL                 | ACTIVE                   |
| `database_name`                       | NVARCHAR(100)  | Name of the database                          | NULL                 | AdventureWorks           |
| `ag_name`                             | NVARCHAR(100)  | Name of the Availability Group               | NULL                 | MyAG                     |
| `automated_backup_preference_desc`    | NVARCHAR(20)   | Description of automated backup preference   | NULL                 | PREFER_SECONDARY         |
| `role_desc`                           | NVARCHAR(20)   | Description of the AG role                    | NULL                 | PRIMARY                  |
| `synchronization_state_desc`          | NVARCHAR(20)   | Description of synchronization state         | NULL                 | SYNCHRONIZED             |
| `availability_mode_desc`              | NVARCHAR(20)   | Description of availability mode             | NULL                 | SYNCHRONOUS_COMMIT       |
| `failover_mode_desc`                  | NVARCHAR(20)   | Description of failover mode                 | NULL                 | MANUAL                   |
| `primary_role_allow_connections_desc` | NVARCHAR(10)   | Description of primary role allow connections| NULL                 | READ_WRITE               |
| `secondary_role_allow_connections_desc`| NVARCHAR(10)  | Description of secondary role allow connections| NULL                | READ_ONLY                |
| `is_commit_participant`               | BIT             | Indicates if the server is a commit participant| NULL                | 1                        |
| `synchronization_health_desc`         | NVARCHAR(10)   | Description of synchronization health       | NULL                 | HEALTHY                  |
| `last_commit_time`                    | DATETIME       | Date and time of last commit                 | NULL                 | 2024-03-06 12:00:00      |
| `collect_date`                        | DATETIME       | Date and time of data collection              | NULL                 | 2024-03-06 20:00:00      |

### Indexes

- `ix_server_ag_information_sql_instance`: Clustered index on the `SQLInstance` column for faster lookup of SQL Instances.

### Script

- [server_ag_information](../scripts/server_ag_information.md)
