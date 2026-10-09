# server_logshipping_information

### Description

This table contains information about log shipping configuration on SQL Server instances.

### Schema

- raw

### Table Columns

| Column Name                  | Data Type    | Description                                      | Constraints         | Example Values           |
|------------------------------|--------------|--------------------------------------------------|----------------------|--------------------------|
| `SQLInstance`                | VARCHAR(50)  | SQL Server instance name                         | NULL                 | ServerA                  |
| `primary_server`             | VARCHAR(100) | Name of the primary server                       | NULL                 | PrimaryServer1           |
| `primary_database`           | VARCHAR(100) | Name of the primary database                     | NULL                 | PrimaryDatabase1         |
| `restore_delay`              | INT          | Restore delay in minutes                         | NULL                 | 30                       |
| `time_since_last_restore`    | INT          | Time since last restore in minutes               | NULL                 | 60                       |
| `last_copied_date`           | DATETIME     | Date and time of the last log file copy          | NULL                 | 2024-03-06 08:00:00      |
| `last_restored_date`         | DATETIME     | Date and time of the last restore operation      | NULL                 | 2024-03-06 09:00:00      |
| `last_copied_file`           | VARCHAR(256) | Name of the last log file copied                  | NULL                 | LogFile1.ldf             |
| `last_restored_file`         | VARCHAR(256) | Name of the last log file restored                | NULL                 | LogFile2.ldf             |
| `disconnect_users`           | BIT          | Flag indicating whether users are disconnected   | NULL                 | 1                        |
| `backup_source_directory`    | VARCHAR(1024)| Source directory for log backups                 | NULL                 | /backup/logs             |
| `backup_destination_directory`| VARCHAR(1024)| Destination directory for log backups            | NULL                 | \\backup\logs            |
| `monitor_server`             | VARCHAR(100) | Name of the monitor server                       | NULL                 | MonitorServer1           |
| `collect_date`               | DATETIME     | Date and time of data collection                 | NULL                 | 2024-03-06 20:00:00      |

### Indexes

- `ix_server_logshipping_information_sql_instance`: Clustered index on the `SQLInstance` column for faster lookup of SQL Instances.


### Script

- [server_logshipping_information](../scripts/server_logshipping_information.md)
