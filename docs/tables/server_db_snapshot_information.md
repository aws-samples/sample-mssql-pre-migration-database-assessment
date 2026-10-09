# server_db_snapshot_information

### Description

This table contains information about database snapshots on SQL Server instances.

### Schema

- raw

### Table Columns

| Column Name            | Data Type       | Description                           | Constraints    | Example Values      |
|------------------------|-----------------|---------------------------------------|----------------|---------------------|
| `SQLInstance`          | VARCHAR(50)     | SQL Server instance name              | NULL           | ServerA             |
| `SnapshotDatabaseName` | VARCHAR(100)    | Name of the database snapshot         | NULL           | SnapshotDB          |
| `SourceDatabaseName`   | VARCHAR(100)    | Name of the source database           | NULL           | SourceDB            |
| `create_date`          | DATETIME        | Date and time of snapshot creation    | NULL           | 2024-03-06 08:00:00|
| `collect_date`         | DATETIME        | Date and time of data collection      | NULL           | 2024-03-06 20:00:00|

### Indexes

- `ix_server_db_snapshot_information_sql_instance`: Clustered index on the `SQLInstance` column for faster lookup of SQL Instances.


### Script

- [server_db_snapshot_information](../scripts/server_db_snapshot_information.md)
