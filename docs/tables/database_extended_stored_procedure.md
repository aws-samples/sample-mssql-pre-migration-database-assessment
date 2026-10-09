# database_extended_stored_procedure

### Description

This table contains information about user procedures that are using Extended Stored Procedures

### Schema

- raw

### Table Columns

| Column Name        | Data Type     | Description                              | Constraints         | Example Values           |
|--------------------|---------------|------------------------------------------|----------------------|--------------------------|
| `SQLInstance`      | VARCHAR(50)   | SQL Server instance name                 | NULL                 | ServerA                  |
| `DatabaseName`       | NVARCHAR(100) | Name of the Database             | NULL                 | AdventureWorks2014                 |
| `ProcedureName`  | NVARCHAR(256)  | Name of the Procedure                  | NULL                 | TestExtendedStoredProcUsage               |
| `Code`     | NVARCHAR(MAX) | Code that shows usage of Extended Stored Procedure        | NULL                 | xp_cmdshell ''dir c:\''         |
| `collect_date`     | DATETIME      | Date and time of data collection         | NULL                 | 2024-03-06 15:20:00      |

### Indexes

- `ix_database_extended_stored_procedure`: Clustered index on the `SQLInstance` and `DatabaseName` column for faster lookup.

### Script

- [database_extended_stored_procedures](../scripts/database_extended_stored_procedure.md)
