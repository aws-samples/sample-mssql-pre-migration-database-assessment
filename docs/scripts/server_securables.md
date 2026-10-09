# server_securables.sql

## Description

This SQL Server script retrieves a list of logins per instance along with their server-level securables. It provides details on the permissions assigned to each login at the server level. The script utilizes system views such as `sys.server_principals` and `sys.server_permissions`.

## Permissions needed

- `ALTER ANY LOGIN`

## Scope

- Server

## Tables queried

- `sys.server_principals`
- `sys.server_permissions`

## Columns

- `SQLInstance`
- `LoginName`
- `Securables`
- `collect_date`

## Sample Results

| SQLInstance | LoginName | Securables                                                                                                            | collect_date          |
|-------------|-----------|-----------------------------------------------------------------------------------------------------------------------|-----------------------|
| ServerName  | Login1    | {"state_desc": "GRANT OR DENY"; "permission_name" : "CONNECT SQL"}, {"state_desc": "GRANT OR DENY"; "permission_name" : "VIEW ANY DATABASE"} | 2024-03-07 10:30:00  |
| ServerName  | Login2    | {"state_desc": "GRANT OR DENY"; "permission_name" : "VIEW ANY DATABASE"}                                             | 2024-03-07 10:31:00  |
