# database_db_audit_information.sql

### Description
This script returns database audit specification created in the database level.

### Permissions needed
- Principals with the ALTER ANY DATABASE AUDIT or VIEW DEFINITION permissions, the dbo role, and members of the db_owners fixed database role have access to this catalog view. In addition, the principal must not be denied VIEW DEFINITION permission.

### Scope
 - Database level

### Tables queried

- sys.server_audits
- sys.database_audit_specifications
- sys.database_audit_specification_details

#### Columns
- SQLInstance
- audit_id
- audit_name
- database_specification_name
- audit_action_name
- is_state_enabled
- is_group
- create_date
- audited_result
- DatabaseName
- collect_date


### AwsDatabaseAssessment Table Name

- raw.database_db_audit_information


### Sample Results

| SQLInstance  |  audit_id | audit_name  | database_specification_name  |  audit_action_name | is_state_enabled | is_group | create_date | audited_result | DatabaseName | collect_date |
|---|---|---|---|---|---|---|---|---|---|---|
|AOAG-NODE-1|65536|OpsSecAudit|DatabaseAuditSpecification-20221207-125732|DATABASE_PERMISSION_CHANGE_GROUP|1|1|2022-12-07 12:58:32.043|SUCCESS AND FAILURE|AdventureWorks2016|2022-12-07 13:01:55.997|
|AOAG-NODE-1|65536|OpsSecAudit|DatabaseAuditSpecification-20221207-125732|SCHEMA_OBJECT_PERMISSION_CHANGE_GROUP|1|1|2022-12-07 12:58:32.043|SUCCESS AND FAILURE|AdventureWorks2016|2022-12-07 13:01:55.997|
