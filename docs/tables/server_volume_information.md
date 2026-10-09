# server_volume_information

### Description

This table stores information about volumes (disk drives) on SQL Server instances.

### Schema

- raw

### Table Columns

| Column Name         | Data Type   | Description                                     | Constraints         | Example Values   |
|---------------------|-------------|-------------------------------------------------|---------------------|------------------|
| `SQLInstance`       | VARCHAR(50) | SQL Server instance name                        | NULL                | ServerA          |
| `DriveLetter`       | NVARCHAR(5) | Drive letter of the volume                      | NULL                | C                |
| `FileSystem`        | NVARCHAR(10) | File system type of the volume                  | NULL                | NTFS             |
| `LogicalVolumeName` | NVARCHAR(50) | Logical name of the volume                      | NULL                | Data             |
| `TotalSizeGB`       | DECIMAL(8,2)| Total size of the volume in gigabytes           | NULL                | 1024.00          |
| `AvailableSizeGB`   | DECIMAL(8,2)| Available size of the volume in gigabytes       | NULL                | 512.00           |
| `SpaceFreePercent`  | DECIMAL(8,2)| Percentage of free space on the volume          | NULL                | 50.00            |
| `CompressedVolume`  | INT         | Indicator for whether the volume is compressed  | NULL                | 0                |
| `collect_date`      | DATETIME    | Date and time of data collection                | NULL                | 2024-03-06 20:00:00 |

### Indexes

- `ix_server_volume_information_sql_instance`: Clustered index on the `SQLInstance` and `DriveLetter` columns for faster lookup of SQL Instances and drive letters.


### Script

- [server_volume_information](../scripts/server_volume_information.md)
