# database_user_securables.sql

### Description

Script to retrieve list of users per database and their securables

### Permissions needed

- ALTER ANY USER

### Scope

- Database

### Tables queried

- sys.database_principals
- sys.database_permissions
- sys.objects
- sys.schemas

#### Columns
- SQLInstance
- UserName
- type_desc
- ObjectName
- roles
- collect_date


### AwsDatabaseAssessment Table Name

- raw.database_user_securables


### Sample Results

| SQLInstance  |  UserName | type_desc  | ObjectName  |  roles | collect_date |
|---|---|---|---|---|---|
EC2AMAZ-GKAF4KU|	securableTest	|SQL_USER|	dbo.ErrorLog|	{"state_desc": "DENY"; "permission_name" : "DELETE"};{"state_desc": "DENY"; "permission_name" : "INSERT"}|	2022-12-13 14:55:16.543|
EC2AMAZ-GKAF4KU|	securableTest|	SQL_USER|	dbo.uspGetBillOfMaterials|	{"state_desc": "GRANT"; "permission_name" : "ALTER"};{"state_desc": "GRANT"; "permission_name" : "TAKE OWNERSHIP"}|	2022-12-13 14:55:16.543|
