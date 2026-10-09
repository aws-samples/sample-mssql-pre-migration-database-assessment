# database_general_information

### Description

This table holds information about each database in a particular SQL Server instance being assessed.


### Schema

- raw


### Table Columns

| Column Name                     | Data Type           | Description                                  | Constraints         | Example Values              |
|---------------------------------|---------------------|----------------------------------------------|----------------------|-----------------------------|
| `SQLInstance`                   | VARCHAR(50)         | SQL Server instance name                     | NULL                 | ServerA|
| `DatabaseID`                    | INT                 | Unique identifier for the database            | NULL                 | 4|
| `DatabaseName`                  | VARCHAR(100)        | Name of the database                         | NULL                 | msdb|
| `CompatibilityLevel`            | INT                 | Database compatibility level                 | NULL                 | 150                   |
| `Owner`                         | NVARCHAR(50)        | Owner of the database                        | NULL                 | sa|
| `CollationName`                 | NVARCHAR(50)        | Database collation name                      | NULL                 | SQL_Latin1_General_CP1_CI_AS |
| `UserAccess`                    | NVARCHAR(20)        | User access mode                             | NULL                 |MULTI_USER|
| `ReadOnlyDatabase`              | BIT                 | Indicates if the database is read-only      | NULL                 | 0|
| `DatabaseState`                 | NVARCHAR(15)        | Current state of the database               | NULL                 | ONLINE|
| `RecoveryModel`                 | NVARCHAR(15)        | Database recovery model                     | NULL                 |SIMPLE|
| `ReadCommittedSnapshotIsolation`| BIT                 | Indicates if Read Committed Snapshot Isolation is enabled | NULL   | 0|
| `SnapshotIsolationState`        | VARCHAR(3)          | State of Snapshot Isolation                | NULL                 | ON|
| `IsDistributorDatabase`         | BIT                 | Indicates if the database is a distributor database | NULL          |0 |
| `IsSubscriberDatabase`          | BIT                 | Indicates if the database is a subscriber database | NULL           |0 |
| `IsPublishedDatabase`           | BIT                 | Indicates if the database is a published database | NULL            |0 |
| `StretchDatabaseEnabled`        | BIT                 | Indicates if Stretch Database is enabled    | NULL                 | 0|
| `last_user_seek`                | DATETIME            | Date and time of the last user seek         | NULL                 | 2023-04-10 14:30:00     |
| `last_user_scan`                | DATETIME            | Date and time of the last user scan         | NULL                 | 2023-04-12 09:15:00     |
| `last_user_lookup`              | DATETIME            | Date and time of the last user lookup       | NULL                 | 2023-04-11 16:45:00     |
| `last_user_update`              | DATETIME            | Date and time of the last user update       | NULL                 | 2023-04-13 11:20:00     |
| `collect_date`                  | DATETIME            | Date and time of data collection            | NULL                 | 2023-04-15 10:00:00     |

### Indexes

- `ix_general_database_information_database_name`: Index on the `SQLInstance` and `DatabaseName` column for faster lookup of SQL Instances and Database Names.

### Script

- [database_general_information](../scripts/database_general_information.md)
