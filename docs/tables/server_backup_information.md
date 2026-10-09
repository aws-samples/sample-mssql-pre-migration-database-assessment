# server_backup_information

### Description

This table contains information about backups performed on databases across SQL Server instances.

### Schema

- raw

### Table Columns

| Column Name              | Data Type       | Description                               | Constraints         | Example Values           |
|--------------------------|-----------------|-------------------------------------------|----------------------|--------------------------|
| `SQLInstance`            | VARCHAR(50)     | SQL Server instance name                  | NULL                 | ServerA                  |
| `DatabaseName`           | VARCHAR(100)    | Name of the database                      | NULL                 | AdventureWorks2019       |
| `BackupType`             | NVARCHAR(20)    | Type of the backup                        | NULL                 | FULL                     |
| `BackupStartDate`        | DATETIME        | Start date and time of the backup         | NULL                 | 2024-03-06 08:00:00      |
| `BackupFinishDate`       | DATETIME        | Finish date and time of the backup        | NULL                 | 2024-03-06 08:30:00      |
| `TotalBackupTimeMinutes` | SMALLINT        | Total duration of the backup in minutes   | NULL                 | 30                       |
| `BackupSize`             | DECIMAL(15,2)   | Total size of the backup in bytes         | NULL                 | 2147483648               |
| `BackupSizeMB`           | DECIMAL(15,2)   | Total size of the backup in megabytes     | NULL                 | 2048.00                  |
| `collect_date`           | DATETIME        | Date and time of data collection          | NULL                 | 2024-03-06 20:00:00      |

### Indexes

- `ix_server_backup_information_sql_instance_database_name`: Clustered index on the `SQLInstance` and `DatabaseName` columns for faster lookup of SQL Instances and databases.


### Script

- [server_backup_information](../scripts/server_backup_information.md)
