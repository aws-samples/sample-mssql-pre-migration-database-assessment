# server_backup_information.sql

### Description

The script retrieves all database backups taken in the last 10 days.

### Permissions needed

- db_datareader on msdb

### Scope

 - Server

### Tables queried

- backupset

#### Columns
- SQLInstance
- DatabaseName
- BackupType
- BackupStartDate
- BackupFinishDate
- TotalBackupTimeMinutes
- BackupSize
- BackupSizeMB
- collect_date


### AwsDatabaseAssessment Table Name

- raw.server_backup_information


### Sample Results

| SQLInstance  |  DatabaseName | BackupType  | BackupStartDate  |  BackupFinishDate | TotalBackupTimeMinutes | BackupSize | BackupSizeMB | collect_date |
|---|---|---|---|---|---|---|---|---|
|AOAG-NODE-1|AdventureWorks2016| Full Backup |2023-01-31 13:55:56.000|2023-01-31 13:55:57.000|1|229733376|219.09|2022-12-07 12:58:32.043|
|AOAG-NODE-1|AdventureWorksDW2016| Full Backup |2023-01-31 13:55:56.000|2023-01-31 13:55:57.000|5|112814080|107.59|2022-12-07 12:58:32.043|
