# database_size_information

### Description

This table holds information about the size of databases on SQL Server instances.

### Schema

- raw

### Table Columns

| Column Name        | Data Type    | Description                             | Constraints         | Example Values           |
|--------------------|--------------|-----------------------------------------|----------------------|--------------------------|
| `SQLInstance`      | VARCHAR(50)  | SQL Server instance name                | NULL                 | ServerA                  |
| `DatabaseName`     | VARCHAR(100) | Name of the database                    | NULL                 | AdventureWorks2019       |
| `FileName`         | NVARCHAR(512)| Logical name of the file                | NULL                 | AdventureWorks.mdf       |
| `PhysicalName`     | NVARCHAR(512)| Physical name of the file               | NULL                 | C:\Data\AdventureWorks.mdf |
| `FileType`         | NVARCHAR(50) | Type of the file (data or log)          | NULL                 | Data                     |
| `FilegroupType`    | NVARCHAR(50) | Type of filegroup                       | NULL                 | PRIMARY                  |
| `TotalSizeinMB`    | DECIMAL(10, 2)| Total size of the file in MB            | NULL                 | 1024.00                  |
| `AvailableSpaceInMB`| DECIMAL(10, 2)| Available space in the file in MB       | NULL                 | 512.00                   |
| `UsedSpaceinMB`    | DECIMAL(10, 2)| Used space in the file in MB            | NULL                 | 512.00                   |
| `collect_date`     | DATETIME     | Date and time of data collection        | NULL                 | 2024-03-05 17:30:00      |

### Indexes

- `ix_database_size_information_sqlinstance_database_name`: Clustered index on the `SQLInstance` and `DatabaseName` columns for faster lookup of SQL Instances and Database Names.

### Script

- [database_size_information](../scripts/database_size_information.md)
