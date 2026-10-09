# server_tde_information

### Description

This table stores information about Transparent Data Encryption (TDE) configuration for databases on SQL Server instances.

### Schema

- raw

### Table Columns

| Column Name               | Data Type    | Description                              | Constraints          | Example Values       |
|---------------------------|--------------|------------------------------------------|----------------------|----------------------|
| `SQLInstance`             | VARCHAR(50)  | SQL Server instance name                 | NULL                 | ServerA              |
| `database_name`           | VARCHAR(100) | Name of the database                     | NULL                 | AdventureWorks       |
| `cert_name`               | VARCHAR(100) | Name of the certificate used for TDE     | NULL                 | TDECertificate       |
| `encryption_state_desc`   | VARCHAR(256) | Description of encryption state          | NULL                 | Encrypted            |
| `key_algorithm`           | VARCHAR(100) | Algorithm used for encryption key        | NULL                 | AES                  |
| `key_length`              | INT          | Length of the encryption key             | NULL                 | 256                  |
| `collect_date`            | DATETIME     | Date and time of data collection         | NULL                 | 2024-03-06 20:00:00  |

### Indexes

- `ix_server_tde_information_sql_instance`: Clustered index on the `SQLInstance` column for faster lookup of SQL Instances.


### Script

- [server_tde_information](../scripts/server_tde_information.md)
