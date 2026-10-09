# database_service_broker_information

### Description

This table contains information about Service Broker configurations on SQL Server instances.

### Schema

- raw

### Table Columns

| Column Name    | Data Type   | Description                          | Constraints         | Example Values           |
|----------------|-------------|--------------------------------------|---------------------|--------------------------|
| `SQLInstance`  | VARCHAR(50) | SQL Server instance name             | NULL                | ServerA                  |
| `name`         | NVARCHAR(128) | Name of the Service Broker entity  | NULL                | MyServiceBroker          |
| `type`         | NVARCHAR(128) | Type of the Service Broker entity  | NULL                | Service                  |
| `create_date`  | DATETIME    | Date and time of creation            | NULL                | 2024-03-06 12:00:00      |
| `modify_date`  | DATETIME    | Date and time of modification        | NULL                | 2024-03-06 12:30:00      |
| `collect_date` | DATETIME    | Date and time of data collection     | NULL                | 2024-03-06 20:00:00      |

### Indexes

- `ix_database_service_broker_information_sql_instance`: Clustered index on the `SQLInstance` column for faster lookup of SQL Instances.

### Script

- [database_service_broker_information](../scripts/database_service_broker_information.md)
