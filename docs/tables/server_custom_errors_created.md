# server_custom_errors_created

### Description

This table contains information about custom errors created on SQL Server instances.

### Schema

- raw

### Table Columns

| Column Name      | Data Type  | Description                           | Constraints    | Example Values      |
|------------------|------------|---------------------------------------|----------------|---------------------|
| `SQLInstance`    | VARCHAR(50)| SQL Server instance name              | NULL           | ServerA             |
| `Message`        | NVARCHAR(255) | Error message                      | NULL           | Custom error message |
| `ErrorID`        | INT        | Unique identifier for the error       | NOT NULL       | 1                   |
| `LanguageID`     | SMALLINT   | Language ID                           | NOT NULL       | 1033                |
| `ErrorSeverity`  | TINYINT    | Severity level of the error           | NULL           | 16                  |
| `collect_date`   | DATETIME   | Date and time of data collection      | NULL           | 2024-03-06 20:00:00 |

### Indexes

- `ix_server_custom_errors_created_sql_instance`: Clustered index on the `SQLInstance` column for faster lookup of SQL Instances.

### Script

- [server_custom_errors_created](../scripts/server_custom_errors_created.md)
