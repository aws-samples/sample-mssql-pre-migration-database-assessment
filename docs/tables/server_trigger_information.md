# server_trigger_information

### Description

This table stores information about Server Level Triggers present on SQL Server instances.

### Schema

- raw

### Table Columns

| Column Name             | Data Type   | Description                                    | Constraints         | Example Values   |
|-------------------------|-------------|------------------------------------------------|---------------------|------------------|
| `SQLInstance`           | VARCHAR(50) | SQL Server instance name                       | NULL                | ServerA          |
| `name`                  | NVARCHAR(128) | Name of the trigger                           | NULL                | trigger1         |
| `parent_class_desc`     | NVARCHAR(128) | Description of the parent class               | NULL                | DATABASE         |
| `type_desc`             | NVARCHAR(50)  | Description of the trigger type               | NULL                | SQL              |
| `create_date`           | DATETIME    | Date and time when the trigger was created    | NULL                | 2024-03-06 15:30:00 |
| `modify_date`           | DATETIME    | Date and time when the trigger was last modified | NULL              | 2024-03-06 15:35:00 |
| `is_ms_shipped`         | BIT         | Indicates if the trigger is Microsoft-shipped | NULL                | 1                |
| `is_disabled`           | BIT         | Indicates if the trigger is disabled           | NULL                | 0                |
| `event_type_desc`       | NVARCHAR(128) | Description of the event type                 | NULL                | INSERT           |
| `event_group_type_desc` | NVARCHAR(128) | Description of the event group type            | NULL                | DML_TRIGGER      |
| `collect_date`          | DATETIME    | Date and time of data collection               | NULL                | 2024-03-06 20:00:00 |

### Indexes

- `ix_server_trigger_information_sql_instance`: Clustered index on the `SQLInstance` column for faster lookup of SQL Instances.


### Script

- [server_trigger_information](../scripts/server_trigger_information.md)
