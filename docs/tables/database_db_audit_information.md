# database_db_audit_information

### Description

This table holds information about the database audit information retrieved from a particular SQL Instance and database being assessed.

### Schema

- raw

### Table Columns


| Column Name               | Data Type            | Description                              | Constraints         | Example Values              |
|---------------------------|----------------------|------------------------------------------|----------------------|-----------------------------|
| `SQLInstance`             | VARCHAR(50)          | SQL Server instance name                  | NULL                 | ServerA|
| `audit_id`                | NVARCHAR(100)       | Unique identifier for audit record        | NULL                 | 65536|
| `audit_name`              | NVARCHAR(250)       | Name of the audit                        | NULL                 | OpsSecAudit|
| `database_specification_name`| NVARCHAR(150)    | Name of database specification            | NULL                 | DatabaseAuditSpecification-20221207-125732|
| `audit_action_name`       | NVARCHAR(150)       | Name of the audited action               | NULL                 | SCHEMA_OBJECT_PERMISSION_CHANGE_GROUP|
| `is_state_enabled`        | BIT                  | Indicates if the audit is enabled        | NULL                 | 1|
| `is_group`                | BIT                  | Indicates if the audit is a group audit  | NULL                 | 1|
| `create_date`             | DATETIME             | Date and time of creation                | NULL                 | 2023-01-15 08:30:00|
| `audited_result`          | NVARCHAR(50)        | Result of the audit                      | NULL                 | SUCCESS AND FAILURE |
| `DatabaseName`            | VARCHAR(100)         | Name of the database                     | NULL                 |AdventureWorks2016|
| `collect_date`            | DATETIME             | Date and time of data collection         | NULL                 | 2023-03-25 10:00:00|


### Indexes

- `ix_database_db_audit_information_sql_instance_database_name`: Index on the `SQLInstance` and `DatabaseName` column for faster lookup of SQL Instances and Database Names.

### Script

- [database_db_audit_information](../scripts/database_db_audit_information.md)
