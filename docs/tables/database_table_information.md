# database_table_information

### Description

This table contains information about tables across databases on SQL Server instances.

### Schema

- raw

### Table Columns

| Column Name    | Data Type     | Description                            | Constraints         | Example Values           |
|----------------|---------------|----------------------------------------|----------------------|--------------------------|
| `SQLInstance`  | NVARCHAR(50) | SQL Server instance name               | NULL                 | ServerA                  |
| `DatabaseName` | NVARCHAR(100)| Name of the database                   | NULL                 | AdventureWorks2019       |
| `SchemaName`   | NVARCHAR(20) | Name of the schema                     | NULL                 | dbo                      |
| `TableName`    | NVARCHAR(150)| Name of the table                      | NULL                 | Customers                |
| `collect_date` | DATETIME      | Date and time of data collection       | NULL                 | 2024-03-06 20:00:00      |

### Indexes

- `ix_database_table_information_sql_instance`: Clustered index on the `SQLInstance`, `DatabaseName`, and `TableName` columns for faster lookup of SQL Instances and tables.

### Script

- [database_table_information](../scripts/database_table_information.md)
