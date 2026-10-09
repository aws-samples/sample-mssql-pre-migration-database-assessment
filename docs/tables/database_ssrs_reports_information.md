# database_ssrs_reports_information

### Description

This table contains information about SQL Server Reporting Services (SSRS) reports on SQL Server instances.

### Schema

- raw

### Table Columns

| Column Name     | Data Type      | Description                             | Constraints         | Example Values           |
|-----------------|----------------|-----------------------------------------|----------------------|--------------------------|
| `SQLInstance`   | VARCHAR(50)    | SQL Server instance name                | NULL                 | ServerA                  |
| `ItemID`        | NVARCHAR(50)   | ID of the SSRS report item              | NULL                 | 123456                   |
| `Path`          | NVARCHAR(128)  | Path of the SSRS report                 | NULL                 | /Reports/Finance         |
| `Name`          | NVARCHAR(100)  | Name of the SSRS report                 | NULL                 | SalesReport              |
| `ParentID`      | NVARCHAR(128)  | ID of the parent item                   | NULL                 | 654321                   |
| `TypeName`      | NVARCHAR(50)   | Type of the SSRS report item            | NULL                 | Report                   |
| `LinkSourceID`  | NVARCHAR(100)  | ID of the linked source                 | NULL                 | 987654                   |
| `Description`   | NVARCHAR(256)  | Description of the SSRS report          | NULL                 | Monthly sales report     |
| `Hidden`        | BIT            | Indicates if the report is hidden      | NULL                 | 0                        |
| `CreatedBy`     | NVARCHAR(50)   | Name of the user who created the report | NULL                 | JohnDoe                  |
| `CreationDate`  | DATETIME       | Date and time of report creation        | NULL                 | 2024-03-06 12:00:00      |
| `ModifiedBy`    | NVARCHAR(50)   | Name of the user who modified the report| NULL                 | JaneDoe                  |
| `ModifiedDate`  | DATETIME       | Date and time of report modification    | NULL                 | 2024-03-06 12:30:00      |
| `collect_date`  | DATETIME       | Date and time of data collection        | NULL                 | 2024-03-06 20:00:00      |

### Indexes

- `ix_database_ssrs_reports_information_sql_instance`: Clustered index on the `SQLInstance` column for faster lookup of SQL Instances.


### Script

- [database_ssrs_reports_information](../scripts/database_ssrs_reports_information.md)
