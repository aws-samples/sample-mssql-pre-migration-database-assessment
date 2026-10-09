# server_cluster_information

### Description

This table contains information about SQL Server cluster nodes on SQL Server instances.

### Schema

- raw

### Table Columns

| Column Name        | Data Type   | Description                            | Constraints         | Example Values    |
|--------------------|-------------|----------------------------------------|----------------------|-------------------|
| `SQLInstance`      | VARCHAR(50) | SQL Server instance name               | NULL                 | ServerA           |
| `NodeName`         | NVARCHAR(50)| Name of the cluster node               | NULL                 | Node1             |
| `collect_date`     | DATETIME    | Date and time of data collection      | NULL                 | 2024-03-06 20:00:00 |

### Indexes

- `ix_server_cluster_information_sql_instance`: Clustered index on the `SQLInstance` column for faster lookup of SQL Instances.

### Script

- [server_cluster_information](../scripts/server_cluster_information.md)
