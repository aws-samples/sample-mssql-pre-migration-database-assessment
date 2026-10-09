# master_applications

### Description

This table holds data that has been extracted from the Migration Portfolio Analysis (MPA) tool. It is used when generating application questionnaires to be shared with application teams.

### Schema

- mpa

### Table Columns


| Column Name               | Data Type       | Description        | Constraints| Example Values     |
|---------------------------|-----------------|--------------------|------------|------------------|
| `ApplicationId`           | NVARCHAR(50)    | Application ID     | NULL       | UTR07102-NON-PROD|
| `ApplicationName`         | NVARCHAR(100)   | Application Name   | NULL       | USSD|



### Indexes

- `ix_master_applications`: Index on the `ApplicationId`.

### Script

- N/A
