# mpa.ConfirmDatabaseUsers

## Description

The purpose of this stored procedure is to generate a list of database users, their roles, and permissions associated with a specific SQL Server instance (@SQLInstance). This is used for planning the migration of a SQL Server database, and understand which users needs to be moved.


## Permissions needed

- db_owner



## Tables queried

- dbo.vw_logins_and_users_instance
- dbo.logins_exclusion_list
- mpa.master_applications
- mpa.master_databases

## Parameters

| Parameter Name  | Data Type   | Description                                     |
|-----------------|-------------|-------------------------------------------------|
| `@ApplicationName`    | varchar(100) | Input parameter representing the name of the application. |
| `@Environment`    | varchar(50) | Input parameter representing the environment of which you are trying to get the users. |


## Usage

To execute the `mpa.ConfirmDatabaseUsers` stored procedure, follow these steps:

1. Open a SQL query window in your database management tool.
2. Use the following SQL command to call the procedure:

```sql
EXEC mpa.ConfirmDatabaseUsers @ApplicationName = 'Sales Tool', @Environment = 'Development' ;
```

### Sample Results

| SQLInstance  | DatabaseName | UserType | DatabaseUser  | DatabaseRoles  | DatabaseSecurables | ServerRoles | ServerSecurables | Migrate | ExtraNotes |
|-----------------|--------------|--------------|----------|-----------------------------|--------------|--------------|--------------|--------------|--------------|
| SQLServer1      | msdb         | SQL_USER | User1 | db_datareader;db_datawriter | {"object_name": "dbo.agent_datetime"; "state_desc": "GRANT"; "permission_name" : "EXECUTE"} | N/A | {"state_desc": "GRANT"; "permission_name" : "CONNECT SQL"};{"state_desc": "GRANT"; "permission_name" : "VIEW SERVER STATE"} |  YES |  |
| SQLServer1      | msdb         | SQL_USER | User2  | db_backupoperator;db_denydatareader | N/A | dbcreator | {"state_desc": "GRANT"; "permission_name" : "CONNECT SQL"};{"state_desc": "GRANT"; "permission_name" : "VIEW ANY DEFINITION"};{"state_desc": "GRANT"; "permission_name" : "VIEW SERVER STATE"} |  YES |  |
