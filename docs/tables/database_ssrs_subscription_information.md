# database_ssrs_subscription_information

### Description

This table contains information about subscriptions in SQL Server Reporting Services (SSRS) on SQL Server instances.

### Schema

- raw

### Table Columns

| Column Name          | Data Type      | Description                              | Constraints         | Example Values           |
|----------------------|----------------|------------------------------------------|----------------------|--------------------------|
| `SQLInstance`        | VARCHAR(50)    | SQL Server instance name                 | NULL                 | ServerA                  |
| `SubscriptionOwner`  | NVARCHAR(255) | Owner of the subscription                | NULL                 | JohnDoe                  |
| `ModifiedDate`       | DATETIME       | Date and time of modification            | NULL                 | 2024-03-06 12:30:00      |
| `Description`        | NVARCHAR(MAX) | Description of the subscription          | NULL                 | Monthly report delivery  |
| `EventType`          | NVARCHAR(255) | Type of event triggering the subscription| NULL                 | ReportExecution          |
| `DeliveryExtension`  | NVARCHAR(255) | Delivery extension used for subscription | NULL                 | Email                    |
| `LastStatus`         | NVARCHAR(255) | Last status of the subscription          | NULL                 | Delivered                |
| `LastRunTime`        | DATETIME       | Date and time of last run                | NULL                 | 2024-03-06 10:00:00      |
| `NextRunTime`        | DATETIME       | Date and time of next run                | NULL                 | 2024-04-06 10:00:00      |
| `ScheduleName`       | NVARCHAR(255) | Name of the schedule for subscription    | NULL                 | Weekly                   |
| `ReportPath`         | NVARCHAR(MAX) | Path of the report associated with subscription | NULL            | /Reports/Finance         |
| `ReportDescription`  | NVARCHAR(MAX) | Description of the report                | NULL                 | Sales report             |
| `Parameters`         | NVARCHAR(MAX) | Parameters for the subscription          | NULL                 | {"StartDate": "2024-03-01", "EndDate": "2024-03-31"} |
| `collect_date`       | DATETIME       | Date and time of data collection         | NULL                 | 2024-03-06 20:00:00      |

### Indexes

- `ix_database_ssrs_subscriptions_information_sql_instance`: Clustered index on the `SQLInstance` column for faster lookup of SQL Instances.

### Script

- [database_ssrs_subscription_information](../scripts/database_ssrs_subscription_information.md)
