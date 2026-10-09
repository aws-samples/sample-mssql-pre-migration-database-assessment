# database_user_permissions.sql

### Description

Script to retrieve list of users per database and their permissions

### Permissions needed
- ALTER ANY USER

### Scope

- Database

### Tables queried

- sys.database_principals
- sys.database_role_members

#### Columns
- SQLInstance
- DatabaseName
- DatabaseUser
- UserType
- CreateDate
- Roles
- collect_date


### AwsDatabaseAssessment Table Name

- raw.database_user_permissions


### Sample Results

| SQLInstance  |  DatabaseName | DatabaseUser  | UserType  |  CreateDate | Roles | collect_date |
|---|---|---|---|---|---|---|
AOAG-NODE-1|AdventureWorks2016|aws_dms|SQL_USER|2022-11-30 12:26:58.763|db_backupoperator;db_datawriter;db_ddladmin	|2022-12-13 14:47:48.110|
