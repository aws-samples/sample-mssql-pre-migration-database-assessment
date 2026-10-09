# server_agent_alerts

### Description

This table contains information about SQL Server Agent alerts on SQL Server instances.

### Schema

- raw

### Table Columns

| Column Name                | Data Type     | Description                                   | Constraints         | Example Values           |
|----------------------------|---------------|-----------------------------------------------|----------------------|--------------------------|
| `SQLInstance`              | VARCHAR(50)   | SQL Server instance name                      | NULL                 | ServerA                  |
| `AlertName`                | NVARCHAR(128) | Name of the alert                             | NULL                 | Disk Space Alert         |
| `EventSource`              | NVARCHAR(50)  | Source of the event triggering the alert      | NULL                 | SQLServer                |
| `MessageID`                | INT           | ID of the message associated with the alert   | NULL                 | 50000                    |
| `severity`                 | SMALLINT      | Severity level of the alert                   | NULL                 | 16                       |
| `Enabled`                  | INT           | Indicates if the alert is enabled             | NULL                 | 1                        |
| `has_notification`         | INT           | Indicates if the alert has notification       | NULL                 | 0                        |
| `delay_between_responses`  | INT           | Delay between responses for the alert (in seconds) | NULL             | 300                      |
| `occurrence_count`         | INT           | Number of occurrences of the alert            | NULL                 | 3                        |
| `last_occurrence_date`     | INT           | Date of the last occurrence of the alert      | NULL                 | 20240306                 |
| `last_occurrence_time`     | INT           | Time of the last occurrence of the alert      | NULL                 | 124500                   |
| `collect_date`             | DATETIME      | Date and time of data collection              | NULL                 | 2024-03-06 20:00:00      |

### Indexes

- `ix_server_agent_alerts_sql_instance`: Clustered index on the `SQLInstance` column for faster lookup of SQL Instances.

### Script

- [server_agent_alerts](../scripts/server_agent_alerts.md)
