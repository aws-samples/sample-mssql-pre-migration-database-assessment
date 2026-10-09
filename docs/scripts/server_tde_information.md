# server_tde_information.sql

## Description

This SQL Server script checks if a database is using Transparent Data Encryption (TDE). It lists all encrypted databases along with details on the certificate used for encryption. The script retrieves information from the system views `sys.dm_database_encryption_keys`, `sys.certificates`, and `sys.databases`.

## Permissions needed

- `VIEW SERVER STATE`

## Scope

- Server

## Tables queried

- `sys.dm_database_encryption_keys`
- `sys.certificates`
- `sys.databases`

## Columns

- `SQLInstance`
- `database_name`
- `cert_name`
- `encryption_state_desc`
- `key_algorithm`
- `key_length`
- `collect_date`

## Sample Results

| SQLInstance | database_name | cert_name | encryption_state_desc | key_algorithm | key_length | collect_date          |
|-------------|---------------|-----------|-----------------------|---------------|------------|-----------------------|
| ServerName  | Database1     | Cert1     | Encrypted             | AES           | 256        | 2024-03-07 10:30:00  |
| ServerName  | Database2     | Cert2     | Unencrypted           | NULL          | NULL       | 2024-03-07 10:31:00  |
