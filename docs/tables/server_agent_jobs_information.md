# server_agent_jobs_information

### Description

This table holds information about SQL Server Agent jobs on SQL Server instances.

### Schema

- raw

### Table Columns

| Column Name               | Data Type    | Description                                   | Constraints   | Example Values           |
|---------------------------|--------------|-----------------------------------------------|---------------|--------------------------|
| `SQLInstance`             | VARCHAR(50)  | SQL Server instance name                      | NULL          | ServerA                  |
| `JobName`                 | NVARCHAR(128)| Name of the SQL Server Agent job              | NULL          | BackupJob                |
| `enabled`                 | TINYINT      | Indicator if the job is enabled               | NULL          | 1                        |
| `description`             | NVARCHAR(512)| Description of the SQL Server Agent job       | NULL          | Daily backup job         |
| `JobOwner`                | NVARCHAR(50) | Owner of the SQL Server Agent job             | NULL          | sa                       |
| `JobCategoryName`         | NVARCHAR(50) | Category name of the SQL Server Agent job     | NULL          | Maintenance              |
| `step_id`                 | INT          | Step ID of the SQL Server Agent job step      | NULL          | 1                        |
| `step_name`               | NVARCHAR(128)| Name of the SQL Server Agent job step         | NULL          | BackupDatabase           |
| `subsystem`               | NVARCHAR(50) | Subsystem of the SQL Server Agent job step    | NULL          | T-SQL                    |
| `database_name`           | NVARCHAR(100)| Name of the database involved in the job step | NULL          | AdventureWorks           |
| `command`                 | NVARCHAR(MAX)| T-SQL command executed by the job step        | NULL          | BACKUP DATABASE ...      |
| `On_Success`              | NVARCHAR(20) | Action to take on job step success            | NULL          | QuitWithSuccess          |
| `On_Failure`              | NVARCHAR(20) | Action to take on job step failure            | NULL          | QuitWithFailure          |
| `notify_level_eventlog`   | INT          | Event log notification level                  | NULL          | 1                        |
| `notify_level_email`      | INT          | Email notification level                      | NULL          | 2                        |
| `notify_email_operator_id`| INT          | ID of the operator to notify via email        | NULL          | 1                        |
| `delete_level`            | INT          | Deletion level                                | NULL          | 0                        |
| `collect_date`            | DATETIME     | Date and time of data collection              | NULL          | 2024-03-05 13:30:00      |

### Indexes

- `ix_server_agent_jobs_information_sql_instance`: Clustered index on the `SQLInstance` column for faster lookup of SQL Instances.

### Script

- [server_agent_jobs_information](../scripts/server_agent_jobs_information.md)
