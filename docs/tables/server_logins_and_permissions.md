# server_logins_and_permissions

### Description

This table contains information about server logins and their permissions on SQL Server instances.

### Schema

- raw

### Table Columns

| Column Name    | Data Type    | Description                            | Constraints         | Example Values           |
|----------------|--------------|----------------------------------------|----------------------|--------------------------|
| `SQLInstance`  | VARCHAR(50)  | SQL Server instance name                | NULL                 | ServerA                  |
| `LoginName`    | NVARCHAR(250)| Name of the server login                | NULL                 | john.doe                 |
| `Roles`        | NVARCHAR(2500)| Roles assigned to the server login     | NULL                 | sysadmin, securityadmin  |
| `collect_date` | DATETIME     | Date and time of data collection        | NULL                 | 2024-03-05 15:00:00      |

### Indexes

- `ix_server_logins_and_permissions_sql_instance_login_name`: Clustered index on the `SQLInstance` and `LoginName` columns for faster lookup of SQL Instances and Login Names.


### Script

- [server_logins_and_permissions](../scripts/server_logins_and_permissions.md)
