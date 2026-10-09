# server_securables

### Description

This table stores information about securables assigned to logins on SQL Server instances.

### Schema

- raw

### Table Columns

| Column Name    | Data Type     | Description                                   | Constraints         | Example Values       |
|----------------|---------------|-----------------------------------------------|----------------------|----------------------|
| `SQLInstance`  | VARCHAR(50)   | SQL Server instance name                      | NULL                 | ServerA              |
| `LoginName`    | VARCHAR(100)  | Name of the login                             | NULL                 | user_login           |
| `securables`   | NVARCHAR(2500)| List of securables assigned to the login      | NULL                 | securable1, securable2, securable3 |
| `collect_date` | DATETIME      | Date and time of data collection              | NULL                 | 2024-03-06 20:00:00  |

### Indexes

- `ix_server_securables_sql_instance`: Clustered index on the `SQLInstance` column for faster lookup of SQL Instances.


### Script

- [server_securables](../scripts/server_securables.md)
