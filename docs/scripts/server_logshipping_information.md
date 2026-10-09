# server_logshipping_information.sql

## Description

This SQL Server script checks if the database has Log Shipping configured. It retrieves details such as SQL instance name, primary server, primary database, restore delay, time since last restore, last copied date, last restored date, last copied file, last restored file, disconnect users status, backup source directory, backup destination directory, monitor server, and collection date from the system tables `msdb.dbo.log_shipping_secondary`, `msdb.dbo.log_shipping_secondary_databases`, and `msdb.dbo.log_shipping_monitor_secondary`.

## Permissions needed

- `db_datareader` on the `msdb` database

## Scope

- Server

## Tables queried

- `msdb.dbo.log_shipping_secondary`
- `msdb.dbo.log_shipping_secondary_databases`
- `msdb.dbo.log_shipping_monitor_secondary`

## Columns

- `SQLInstance`
- `PrimaryServer`
- `PrimaryDatabase`
- `RestoreDelay`
- `TimeSinceLastRestore`
- `LastCopiedDate`
- `LastRestoredDate`
- `LastCopiedFile`
- `LastRestoredFile`
- `DisconnectUsers`
- `BackupSourceDirectory`
- `BackupDestinationDirectory`
- `MonitorServer`
- `collect_date`

## Sample Results

| SQLInstance | PrimaryServer | PrimaryDatabase | RestoreDelay | TimeSinceLastRestore | LastCopiedDate     | LastRestoredDate   | LastCopiedFile | LastRestoredFile | DisconnectUsers | BackupSourceDirectory | BackupDestinationDirectory | MonitorServer | collect_date          |
|-------------|---------------|-----------------|--------------|----------------------|--------------------|--------------------|----------------|------------------|-----------------|-----------------------|-----------------------------|----------------|-----------------------|
| ServerName  | Primary1      | Database1       | 0            | 10                   | 2024-03-07 10:30:00| 2024-03-07 10:29:00| File1          | File2            | 0               | SourceDir1            | DestDir1                    | Monitor1       | 2024-03-07 10:31:00   |
| ServerName  | Primary2      | Database2       | 0            | 5                    | 2024-03-07 10:25:00| 2024-03-07 10:20:00| File3          | File4            | 1               | SourceDir2            | DestDir2                    | Monitor2       | 2024-03-07 10:32:00   |
