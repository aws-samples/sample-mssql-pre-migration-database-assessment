# server_replication_information

### Description

This table contains information about replication setup on SQL Server instances.

### Schema

- raw

### Table Columns

| Column Name            | Data Type    | Description                            | Constraints         | Example Values      |
|------------------------|--------------|----------------------------------------|----------------------|----------------------|
| `SQLInstance`          | VARCHAR(50)  | SQL Server instance name               | NULL                 | ServerA              |
| `publisher_id`         | NVARCHAR(50) | Publisher ID                           | NULL                 | Publisher01          |
| `publisher_db`         | VARCHAR(100) | Publisher database name                | NULL                 | AdventureWorks       |
| `PublicationName`      | NVARCHAR(128)| Name of the publication                | NULL                 | SalesPublication     |
| `ReplicationType`      | NVARCHAR(50) | Type of replication (e.g., transactional, merge) | NULL          | Transactional        |
| `VendorName`           | NVARCHAR(50) | Name of the replication vendor        | NULL                 | Microsoft            |
| `ReplicationDescription`| NVARCHAR(512)| Description of the replication setup  | NULL                 | Replication setup... |
| `collect_date`         | DATETIME     | Date and time of data collection       | NULL                 | 2024-03-06 20:00:00 |

### Indexes

- `ix_server_replication_information_sql_instance`: Clustered index on the `SQLInstance` column for faster lookup of SQL Instances.


### Script

- [server_replication_information](../scripts/server_replication_information.md)
