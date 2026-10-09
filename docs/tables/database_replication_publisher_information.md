# database_replication_publisher_information

### Description

This table contains information about replication publishers on SQL Server instances.

### Schema

- raw

### Table Columns

| Column Name            | Data Type     | Description                            | Constraints         | Example Values           |
|------------------------|---------------|----------------------------------------|----------------------|--------------------------|
| `SQLInstance`          | VARCHAR(50)   | SQL Server instance name               | NULL                 | ServerA                  |
| `PublisherDatabase`    | NVARCHAR(100) | Name of the publisher database         | NULL                 | PublisherDB              |
| `PublicationName`      | NVARCHAR(128) | Name of the publication                | NULL                 | MyPublication            |
| `SchemaName`           | VARCHAR(50)   | Name of the schema                     | NULL                 | dbo                      |
| `TableName`            | NVARCHAR(150) | Name of the table                      | NULL                 | MyTable                  |
| `SubscriberServerName` | NVARCHAR(50)  | Name of the subscriber server          | NULL                 | SubscriberServer          |
| `collect_date`         | DATETIME      | Date and time of data collection       | NULL                 | 2024-03-06 20:00:00      |

### Indexes

- `ix_database_replication_publisher_information_sql_instance`: Clustered index on the `SQLInstance` column for faster lookup of SQL Instances.

### Script

- [database_replication_publisher_information](../scripts/database_replication_publisher_information.md)
