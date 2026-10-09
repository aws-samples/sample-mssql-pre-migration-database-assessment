# database_inmemory_information

### Description

This table contains information about in-memory objects in databases on SQL Server instances.

### Schema

- raw

### Table Columns

| Column Name      | Data Type     | Description                              | Constraints         | Example Values           |
|------------------|---------------|------------------------------------------|----------------------|--------------------------|
| `SQLInstance`    | VARCHAR(50)   | SQL Server instance name                 | NULL                 | ServerA                  |
| `DatabaseName`   | VARCHAR(256)  | Name of the database                     | NULL                 | AdventureWorks2019       |
| `SchemaName`     | VARCHAR(50)   | Name of the schema                       | NULL                 | dbo                      |
| `TableName`      | VARCHAR(256)  | Name of the in-memory table              | NULL                 | InMemoryTable            |
| `durability_desc`| NVARCHAR(60)  | Description of durability                | NULL                 | SCHEMA_ONLY              |
| `create_date`    | DATETIME      | Date and time of creation                | NOT NULL             | 2024-03-06 12:00:00      |
| `modify_date`    | DATETIME      | Date and time of modification            | NOT NULL             | 2024-03-06 12:30:00      |
| `collect_date`   | DATETIME      | Date and time of data collection         | NULL                 | 2024-03-06 16:45:00      |

### Indexes

- `ix_database_inmemory_information_sql_instance_database_name`: Clustered index on the `SQLInstance` column and `DatabaseName` column for faster lookup of SQL Instances.


### Script

- [database_inmemory_information](../scripts/database_inmemory_information.md)
