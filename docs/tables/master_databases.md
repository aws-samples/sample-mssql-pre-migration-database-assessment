# master_databases

### Description

This table holds data that has been extracted from the Migration Portfolio Analysis (MPA) tool. It is used when generating application questionnaires to be shared with application teams.

### Schema

- mpa

### Table Columns


| Column Name               | Data Type        | Description                        | Constraints      | Example Values     |
|---------------------------|------------------|------------------------------------|------------------|--------------------|
| `SQLInstance`             | VARCHAR(50)      | SQL Server instance name           | NULL             | ServerA|
| `DatabaseName`            | NVARCHAR(100)    | Database Name    | NULL            | msdb             |
| `ApplicationId`           | NVARCHAR(50)     | Application Id                     | NULL             | UTR07102-NON-PROD|


### Indexes

- `ix_master_databases`: Index on the `ApplicationId`.

### Script

- N/A
