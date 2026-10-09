# database_io_utilization

### Description

This table holds information about the input/output (I/O) utilization of databases on SQL Server instances.

### Schema

- raw

### Table Columns

| Column Name      | Data Type       | Description                               | Constraints         | Example Values           |
|------------------|-----------------|-------------------------------------------|----------------------|-------------------------|
| `SQLInstance`    | VARCHAR(50)     | SQL Server instance name                  | NULL                 | ServerA                 |
| `IORank`         | INT             | Rank of I/O utilization                   | NULL                 | 1                       |
| `DatabaseName`   | VARCHAR(100)    | Name of the database                      | NULL                 | AdventureWorks2019      |
| `TotalIOMB`      | DECIMAL(12, 2)  | Total I/O in MB                           | NULL                 | 1024.00                 |
| `TotalIOPercent` | DECIMAL(12, 2)  | Total I/O percentage                      | NULL                 | 50.00                   |
| `ReadIOMB`       | DECIMAL(12, 2)  | Read I/O in MB                            | NULL                 | 512.00                  |
| `ReadIOPercent`  | DECIMAL(8, 2)   | Read I/O percentage                       | NULL                 | 25.00                   |
| `WriteIOMB`      | DECIMAL(12, 2)  | Write I/O in MB                           | NULL                 | 512.00                  |
| `WriteIOPercent` | DECIMAL(8, 2)   | Write I/O percentage                      | NULL                 | 25.00                   |
| `collect_date`   | DATETIME        | Date and time of data collection          | NULL                 | 2024-03-05 18:30:00     |

### Indexes

- `ix_database_io_utilization_sql_instance`: Clustered index on the `SQLInstance` and `DatabaseName` columns for faster lookup of SQL Instances and Database Names.

### Script

- [database_io_utilization](../scripts/database_io_utilization.md)
