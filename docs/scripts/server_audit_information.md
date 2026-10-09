# server_audit_information.sql

### Description

Script to list the existing server audit specifications.

### Permissions needed

- VIEW ANY DEFINITION

### Scope

- Server

### Tables queried

- sys.server_audits
- sys.server_audit_specifications
- sys.server_audit_specification_details

#### Columns
- SQLInstance
- audit_id
- audit_name
- server_specification_name
- audit_action_name
- is_state_enabled
- is_group
- audit_action_id
- create_date
- modify_date
- collect_date


### AwsDatabaseAssessment Table Name

- raw.server_audit_information


### Sample Results

| SQLInstance  |  audit_id | audit_name  | server_specification_name  |  audit_action_name | is_state_enabled | is_group | audit_action_id | create_date | modify_date| collect_date|
|---|---|---|---|---|---|---|---|---|---|---|
AOAG-NODE-1|65536|OpsSecAudit|ServerAuditSpecification-20221207-125635|SERVER_OBJECT_PERMISSION_CHANGE_GROUP|1|1|GRSO|2022-12-07 12:57:22.490|2022-12-07 12:57:22.490|2022-12-13 16:42:11.063|
