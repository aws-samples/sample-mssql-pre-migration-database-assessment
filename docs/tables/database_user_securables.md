# database_user_securables

### Description

This table contains information about securables assigned to users across databases on SQL Server instances.

### Schema

- raw

### Table Columns

| Column Name    | Data Type     | Description                            | Constraints         | Example Values           |
|----------------|---------------|----------------------------------------|----------------------|--------------------------|
| `SQLInstance`  | VARCHAR(50)   | SQL Server instance name               | NULL                 | ServerA                  |
| `UserName`     | VARCHAR(100)  | Name of the user                       | NULL                 | JohnDoe                  |
| `type_desc`    | VARCHAR(50)   | Description of the securable type      | NULL                 | SCHEMA                   |
| `securables`   | NVARCHAR(2500)| List of securables assigned to the user| NULL                 | dbo.MyTable, dbo.MyView |
| `collect_date` | DATETIME      | Date and time of data collection       | NULL                 | 2024-03-06 20:00:00      |

### Indexes

- `ix_database_user_securables_sql_instance`: Clustered index on the `SQLInstance` and `UserName` columns for faster lookup of SQL Instances and users.

### Script

- [database_user_securables](../scripts/database_user_securables.md)
