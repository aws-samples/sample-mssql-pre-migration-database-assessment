# server_maintenance_plan_information

### Description

This table contains information about maintenance plans configured on SQL Server instances.

### Schema

- raw

### Table Columns

| Column Name               | Data Type    | Description                                | Constraints         | Example Values           |
|---------------------------|--------------|--------------------------------------------|----------------------|--------------------------|
| `SQLInstance`             | VARCHAR(50)  | SQL Server instance name                   | NULL                 | ServerA                  |
| `MaintenancePlan`         | NVARCHAR(128)| Name of the maintenance plan               | NULL                 | DailyMaintenancePlan     |
| `Description`             | NVARCHAR(512)| Description of the maintenance plan        | NULL                 | Regular database backups |
| `PlanOwner`               | NVARCHAR(50) | Owner of the maintenance plan              | NULL                 | AdminUser                |
| `SubplanName`             | NVARCHAR(128)| Name of the subplan within the plan        | NULL                 | BackupSubplan            |
| `SubplanDescription`      | NVARCHAR(512)| Description of the subplan                 | NULL                 | Subplan for backups      |
| `JobName`                 | NVARCHAR(128)| Name of the associated job                 | NULL                 | BackupJob                |
| `JobDescription`          | NVARCHAR(512)| Description of the associated job          | NULL                 | Job for database backups  |
| `enabled`                 | BIT          | Flag indicating whether the plan is enabled| NULL                 | 1                        |
| `TaskName`                | NVARCHAR(128)| Name of the task within the plan           | NULL                 | BackupTask               |
| `DatabaseName`            | VARCHAR(100) | Name of the database associated with the plan | NULL               | MyDatabase               |
| `collect_date`            | DATETIME     | Date and time of data collection           | NULL                 | 2024-03-06 20:00:00      |

### Indexes

- `ix_server_maintenance_plan_information_sql_instance`: Clustered index on the `SQLInstance` column for faster lookup of SQL Instances.


### Script

- [server_maintenance_plan_information](../scripts/server_maintenance_plan_information.md)
