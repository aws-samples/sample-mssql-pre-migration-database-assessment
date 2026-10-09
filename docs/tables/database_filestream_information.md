# database_filestream_information

### Description

This table contains information about the filestream configuration for databases on SQL Server instances.

### Schema

- raw

### Table Columns

| Column Name                 | Data Type       | Description                          | Constraints  | Example Values          |
|-----------------------------|---------------|----------------------------------------|--------------|-------------------------|
| `SQLInstance`               | NVARCHAR(50)  | SQL Server instance name               | NULL         | ServerA                 |
| `DatabaseName`              | NVARCHAR(100) | Name of the database                   | NULL         | AdventureWorks2019      |
| `non_transacted_access`     | SMALLINT      | Indicator for non-transacted access    | NULL         | 1                       |
| `non_transacted_access_desc`| VARCHAR(15)   | Description of non-transacted access   | NULL         | ALLOW_NO_TRANSACTED_ACCESS |
| `directory_name`            | NVARCHAR(512) | Name of the filestream directory       | NULL         | FileStreamDirectory     |
| `collect_date`              | DATETIME      | Date and time of data collection       | NULL         | 2024-03-05 10:30:00     |

### Indexes

- `ix_database_filestream_information_sql_instance`: Clustered index on the `SQLInstance` column for faster lookup of SQL Instances.


### Script

- [database_filestream_information](../scripts/database_filestream_information.md)
