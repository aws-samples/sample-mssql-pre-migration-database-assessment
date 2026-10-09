# server_volume_information.sql

### Description

This SQL Server query retrieves information about disk drives where database files are hosted. It provides details about drive letter, file system type, logical volume name, total size in gigabytes, available size in gigabytes, free space percentage, and whether the volume is compressed.


### Permissions needed

- VIEW SERVER STATE

### Scope

- Server

### Tables queried

- sys.master_files
- sys.dm_os_volume_stats

#### Columns

- SQLInstance
- DriveLetter
- FileSystem
- LogicalVolumeName
- TotalSizeGB
- AvailableSizeGB
- SpaceFreePercent
- CompressedVolume
- collect_date


### AwsDatabaseAssessment Table Name

- raw.server_volume_information


### Sample Results

| SQLInstance | DriveLetter | FileSystem | LogicalVolumeName | TotalSizeGB | AvailableSizeGB | SpaceFreePercent | CompressedVolume | collect_date         |
|------------|------------|------------|-------------------|------------|-----------------|-----------------|-----------------|---------------------|
| Server1    | C:\          | NTFS       | System            | 237.25     | 42.11           | 17.74           | 0               | 2023-11-07 10:30:00|
| Server1    | D:\          | NTFS       | Data              | 512.00     | 128.45          | 25.09           | 1               | 2023-11-07 10:31:00|
| Server1    | E:\          | exFAT      | Backup            | 1024.00    | 849.73          | 82.96           | 0               | 2023-11-07 10:32:00|
