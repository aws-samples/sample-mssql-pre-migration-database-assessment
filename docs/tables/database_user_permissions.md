# database_user_permissions

### Description

This table holds information about database user permissions on SQL Server Database.

### Schema

- raw

### Table Columns

| Column Name     | Data Type    | Description                                 | Constraints         | Example Values           |
|-----------------|--------------|---------------------------------------------|----------------------|--------------------------|
| `SQLInstance`   | VARCHAR(50)  | SQL Server instance name                     | NULL                 | ServerA                  |
| `DatabaseName`  | VARCHAR(100) | Name of the database                         | NULL                 | AdventureWorks2019       |
| `DatabaseUser`  | VARCHAR(100) | Name of the database user                    | NULL                 | john.doe                 |
| `UserType`      | NVARCHAR(15) | Type of the database user                    | NULL                 | SQL_USER                 |
| `CreateDate`    | DATETIME     | Date and time of user creation               | NULL                 | 2024-03-05 14:00:00      |
| `Roles`         | NVARCHAR(2500)| Roles assigned to the database user         | NULL                 | db_owner, db_datareader  |
| `collect_date`  | DATETIME     | Date and time of data collection             | NULL                 | 2024-03-05 14:30:00      |

### Indexes

- `ix_database_user_permissions_sql_instance`: Clustered index on the `SQLInstance` and `DatabaseName` columns for faster lookup of SQL Instances and Database Names.

### Script

- [database_user_permissions](../scripts/database_user_permissions.md)
