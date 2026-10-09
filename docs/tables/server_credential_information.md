# server_credential_information

### Description

This table contains information about server credentials on SQL Server instances.

### Schema

- raw

### Table Columns

| Column Name            | Data Type       | Description                               | Constraints         | Example Values           |
|------------------------|-----------------|-------------------------------------------|----------------------|--------------------------|
| `SQLInstance`          | VARCHAR(50)     | SQL Server instance name                  | NULL                 | ServerA                  |
| `credential_id`        | INT             | Identifier for the credential             | NULL                 | 1                        |
| `Credential_Name`      | NVARCHAR(128)  | Name of the credential                    | NULL                 | MyCredential             |
| `credential_identity`  | NVARCHAR(50)   | Identity associated with the credential   | NULL                 | domain\user              |
| `Principal_Name`       | NVARCHAR(50)   | Name of the principal                     | NULL                 | dbo                      |
| `type_desc`            | NVARCHAR(128)  | Description of the credential type        | NULL                 | SQL Server Login         |
| `is_disabled`          | BIT             | Indicates if the credential is disabled   | NULL                 | 0                        |
| `default_database_name`| NVARCHAR(128)  | Name of the default database              | NULL                 | master                   |
| `Proxy_Name`           | NVARCHAR(128)  | Name of the proxy                         | NULL                 | MyProxy                  |
| `enabled`              | INT             | Indicates if the credential is enabled    | NULL                 | 1                        |
| `description`          | NVARCHAR(512)  | Description of the credential             | NULL                 | This is a credential     |
| `collect_date`         | DATETIME        | Date and time of data collection          | NULL                 | 2024-03-06 20:00:00      |

### Indexes

- `ix_server_credential_information_sql_instance`: Clustered index on the `SQLInstance` column for faster lookup of SQL Instances.


### Script

- [server_credential_information](../scripts/server_credential_information.md)
