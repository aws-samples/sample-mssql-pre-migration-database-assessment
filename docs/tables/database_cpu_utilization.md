# database_cpu_utilization

### Description

This table holds information about CPU utilization for databases on SQL Server instances.

## Schema

- raw

### Table Columns

| Column Name         | Data Type    | Description                               | Constraints          | Example Values          |
|---------------------|--------------|-------------------------------------------|----------------------|-------------------------|
| `SQLInstance`       | VARCHAR(50)  | SQL Server instance name                  | NULL                 | ServerA                 |
| `CPURank`           | NVARCHAR(5)  | Rank of CPU utilization for the database  | NULL                 | High, Medium, Low       |
| `DatabaseName`      | VARCHAR(100) | Name of the database                      | NULL                 | AdventureWorks2019      |
| `CPUTimeMiliSecond`| NVARCHAR(50) | CPU time in milliseconds                   | NULL                 | 500                     |
| `CPUPercent`        | DECIMAL(8, 2)| CPU utilization percentage                | NULL                 | 25.50                   |
| `collect_date`      | DATETIME     | Date and time of data collection          | NULL                 | 2024-03-05 17:00:00     |

## Indexes

- `ix_cpu_utilization_per_db_sql_instance_database_name`: Clustered index on the `SQLInstance` and `DatabaseName` columns for faster lookup of SQL Instances and Database Names.

## Script

- [database_cpu_utilization](../scripts/database_cpu_utilization.md)
