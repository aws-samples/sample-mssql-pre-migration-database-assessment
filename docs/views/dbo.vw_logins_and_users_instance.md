# dbo.vw_logins_and_users_instance

## Description

This view provides information about logins and users within SQL Server instances and their associated databases. It combines data from the `raw.database_user_permissions`, `raw.server_logins_and_permissions`, `raw.server_securables`, and `raw.database_user_securables` tables. Details such as SQL instance, database name, user type, database user, database roles, database securables, server roles, and server securables are included in the output.

## Schemas Touched

- dbo
- raw

## Permissions

This view requires appropriate permissions to access the following objects:

- [`raw.database_user_permissions`](../tables/database_user_permissions.md)
- [`raw.server_logins_and_permissions`](../tables/server_logins_and_permissions.md)
- [`raw.server_securables`](../tables/server_securables.md)
- [`raw.database_user_securables`](../tables/database_user_securables.md)

## Sample Results

Below is an example of the output you can expect from this view:

| SQLInstance  | DatabaseName        | UserType | DatabaseUser | DatabaseRoles       | DatabaseSecurables       | ServerRoles | ServerSecurables |
|--------------|---------------------|----------|--------------|---------------------|--------------------------|-------------|------------------|
| SQLInstance1 | AdventureWorks2016  | SQL_USER | user1        | db_owner, db_reader | EXECUTE, SELECT, UPDATE  | sysadmin    | ALTER ANY LOGIN  |
| SQLInstance2 | AdventureWorks2016  | SQL_USER | user2        | db_datareader       | N/A                      | public      | CONNECT SQL      |
