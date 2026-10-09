# dbo.vw_database_audit_information

## Description

This view combines information from the `server_audit_information` and `database_db_audit_information` tables to provide an overview of audit settings in SQL Server. It includes details about server-level and database-level audits, their names, and their states.

## Schemas Touched

- dbo
- raw

## Permissions

This view requires appropriate permissions to access the following objects:
- [`raw.server_audit_information`](../tables/server_audit_information.md)
- [`raw.database_db_audit_information`](../tables/database_db_audit_information.md)

## Sample Results

Below is a sample table representing the results you can expect from this view:

| SQLInstance  | ServerAuditName        | ServerAuditEnabled | DatabaseName        | DatabaseAuditName      | database_specification_name                | audit_action_name | DatabaseAuditEnabled |
|--------------|------------------------|--------------------|---------------------|------------------------|--------------------------------------------|-------------------|----------------------|
| SQLInstance1 | Audit-20231103-104512  | 1                  | AdventureWorks2016  | Audit-20231103-104512  | DatabaseAuditSpecification-20231103-104735 | SELECT            | 1                    |
| SQLInstance2 | Audit-20231103-104512  | 1                  | AdventureWorks2016  | Audit-20231103-104512  | DatabaseAuditSpecification-20231103-104735 | SELECT            | 1                    |
