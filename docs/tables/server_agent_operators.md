# server_agent_operators

### Description

This table contains information about SQL Server Agent operators on SQL Server instances.

### Schema

- raw

### Table Columns

| Column Name          | Data Type       | Description                              | Constraints         | Example Values           |
|----------------------|-----------------|------------------------------------------|----------------------|--------------------------|
| `SQLInstance`        | VARCHAR(50)     | SQL Server instance name                 | NULL                 | ServerA                  |
| `name`               | NVARCHAR(128)  | Name of the operator                     | NULL                 | JohnDoe                  |
| `enabled`            | INT             | Indicates if the operator is enabled    | NULL                 | 1                        |
| `email_address`      | NVARCHAR(128)  | Email address of the operator           | NULL                 | john.doe@example.com     |
| `last_email_date`    | INT             | Date of the last email sent             | NULL                 | 20240306                 |
| `last_email_time`    | INT             | Time of the last email sent             | NULL                 | 124500                   |
| `collect_date`       | DATETIME        | Date and time of data collection        | NULL                 | 2024-03-06 20:00:00      |

### Indexes

- `ix_server_agent_operators_sql_instance`: Clustered index on the `SQLInstance` column for faster lookup of SQL Instances.


### Script

- [server_agent_operators](../scripts/server_agent_operators.md)
