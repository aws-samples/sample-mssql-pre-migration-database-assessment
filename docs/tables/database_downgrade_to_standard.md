# database_downgrade_to_standard

### Description

This table contains information about databases that have been downgraded to a standard version on SQL Server instances.

### Schema

- raw

### Table Columns

| Column Name    | Data Type   | Description                            | Constraints         | Example Values           |
|----------------|-------------|----------------------------------------|----------------------|--------------------------|
| `SQLInstance`  | VARCHAR(50) | SQL Server instance name               | NULL                 | ServerA                  |
| `DatabaseName` | VARCHAR(100)| Name of the database                   | NULL                 | AdventureWorks2019       |
| `FeatureName`  | VARCHAR(256)| Name of the feature being downgraded  | NULL                 | SQL Server Replication  |
| `date_collect` | DATETIME    | Date and time of data collection       | NULL                 | 2024-03-06 12:30:00      |

### Indexes

- `ix_database_downgrade_to_standard_sql_instance`: Clustered index on the `SQLInstance` column and `DatabaseName` column for faster lookup of SQL Instances.

### Script

- [database_downgrade_to_standard](../scripts/database_downgrade_to_standard.md)
