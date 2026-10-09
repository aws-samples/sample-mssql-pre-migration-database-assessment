# server_logins_and_permissions.sql

## Description

This SQL Server script collects logins created in the instance and their server permissions. It retrieves details such as SQL instance name, login name, associated server roles, and collection date from the system tables `sys.server_role_members` and `sys.server_principals`.

## Permissions needed

- `VIEW ANY DEFINITION` or `securityadmin` server role

## Scope

- Server

## Tables queried

- `sys.server_role_members`
- `sys.server_principals`

## Columns

- `SQLInstance`
- `LoginName`
- `Roles`
- `collect_date`

## Sample Results

| SQLInstance | LoginName | Roles                                                | collect_date          |
|-------------|-----------|------------------------------------------------------|-----------------------|
| ServerName  | User1     | public;db_owner;db_datareader;db_datawriter;sysadmin | 2024-03-07 10:30:00   |
| ServerName  | User2     | public;db_owner;sysadmin                             | 2024-03-07 10:31:00   |
