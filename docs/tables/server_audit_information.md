# server_audit_information

### Description

This table holds information about the server audit information retrieved from a particular SQL Instance being assessed.

### Schema

- raw

### Table Columns

| Column Name               | Data Type            | Description                              | Constraints         | Example Values              |
|---------------------------|----------------------|------------------------------------------|----------------------|-----------------------------|
| `SQLInstance`             | VARCHAR(50)          | SQL Server instance name                  | NULL                 | ServerA|
| `audit_id`                | NVARCHAR(100)       | Unique identifier for audit record        | NULL                 | 65536|
| `audit_name`              | NVARCHAR(250)       | Name of the audit                        | NULL                 | OpsSecAudit|
| `server_specification_name`| NVARCHAR(100)      | Name of server specification              | NULL                 | ServerAuditSpecification-20221207-125635|
| `audit_action_name`       | NVARCHAR(150)       | Name of the audited action               | NULL                 | SERVER_OBJECT_PERMISSION_CHANGE_GROUP|
| `is_state_enabled`        | BIT                  | Indicates if the audit is enabled        | NULL                 | 1|
| `is_group`                | BIT                  | Indicates if the audit is a group audit  | NULL                 | 1|
| `audit_action_id`         | NVARCHAR(150)       | Identifier for the audited action        | NULL                 | GRSO|
| `create_date`             | DATETIME             | Date and time of creation                | NULL                 | 2023-09-09 10:30:00|
| `modify_date`             | DATETIME             | Date and time of last modification       | NULL                 | 2023-09-09 14:45:00|
| `collect_date`            | DATETIME             | Date and time of data collection         | NULL                 | 2023-09-09 23:59:59|


### Indexes

- `ix_server_audit_information_sql_instance_database_name_table_name`: Index on the `SQLInstance` column for faster lookup of SQL Instances.

### Script

- [server_audit_information](../scripts/server_audit_information.md)
