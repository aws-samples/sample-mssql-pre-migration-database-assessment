# server_credential_information.sql

### Description

Script list the existing credentials and to which SQL Server agent jobs are tied to.

### Permissions needed

- VIEW ANY DEFINITION

### Scope

- Server

### Tables queried

- sys.credentials
- sys.server_principals
- msdb.dbo.sysproxies

#### Columns
- SQLInstance
- credential_id
- Credential_name
- credential_identity
- Principal_name
- type_desc
- is_disabled
- default_database_name
- Proxy_name
- enabled
- description
- collect_date


### AwsDatabaseAssessment Table Name

- raw.server_credential_information


### Sample Results

| SQLInstance  |  credential_id | Credential_name  | credential_identity  |  Principal_name | type_desc | is_disabled | default_database_name | Proxy_name | enabled | description | collect_date |
|---|---|---|---|---|---|---|---|---|---|---|---|
|AOAG-NODE-1|65536|SSISDB|CORP\ssis_op|NULL|NULL|NULL|NULL|SSIS_EXEC|1|NULL|2022-12-07 13:01:55.997|
