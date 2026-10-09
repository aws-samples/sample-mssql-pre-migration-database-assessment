# server_event_notification_information

### Description

This table contains information about event notifications on SQL Server instances.

### Schema

- raw

### Table Columns

| Column Name           | Data Type       | Description                           | Constraints         | Example Values           |
|-----------------------|-----------------|---------------------------------------|----------------------|--------------------------|
| `SQLInstance`         | VARCHAR(50)     | SQL Server instance name              | NULL                 | ServerA                  |
| `name`                | VARCHAR(256)    | Name of the event notification        | NULL                 | Notification1            |
| `object_id`           | INT             | ID of the object associated with the notification | NOT NULL      | 1234                     |
| `parent_class_desc`   | NVARCHAR(60)    | Description of the parent class       | NULL                 | Database                 |
| `create_date`         | DATETIME        | Date and time of notification creation | NOT NULL           | 2024-03-06 08:00:00      |
| `service_name`        | NVARCHAR(256)   | Name of the service associated with the notification | NULL          | Service1                 |
| `collect_date`        | DATETIME        | Date and time of data collection      | NULL                 | 2024-03-06 20:00:00      |

### Indexes

- `ix_server_event_notification_information_sql_instance`: Clustered index on the `SQLInstance` column for faster lookup of SQL Instances.


### Script

- [server_event_notification_information](../scripts/server_event_notification_information.md)
