# server_database_mail_information

### Description

This table contains information about database mail settings on SQL Server instances.

### Schema

- raw

### Table Columns

| Column Name              | Data Type     | Description                          | Constraints         | Example Values           |
|--------------------------|---------------|--------------------------------------|----------------------|--------------------------|
| `SQLInstance`            | VARCHAR(50)   | SQL Server instance name             | NULL                 | ServerA                  |
| `ProfileName`            | NVARCHAR(128)| Name of the mail profile             | NULL                 | Default                  |
| `ProfileDescription`     | NVARCHAR(512)| Description of the mail profile      | NULL                 | Default mail profile      |
| `LastModificationDate`   | DATETIME      | Date of the last modification        | NULL                 | 2024-03-06 20:00:00      |
| `LastModificationUser`   | NVARCHAR(50) | User who last modified the profile   | NULL                 | user1                    |
| `AccountID`              | INT           | ID of the mail account               | NULL                 | 1                        |
| `AccountName`            | NVARCHAR(128)| Name of the mail account             | NULL                 | MailAccount1             |
| `AccountDescription`     | NVARCHAR(512)| Description of the mail account      | NULL                 | Account for sending mails|
| `EmailAddress`           | NVARCHAR(128)| Email address associated with account| NULL                 | example@example.com      |
| `DisplayName`            | NVARCHAR(128)| Display name for the account         | NULL                 | John Doe                 |
| `ReplyToAddress`         | NVARCHAR(128)| Reply-to email address                | NULL                 | replyto@example.com      |
| `ServerType`             | NVARCHAR(128)| Type of the mail server              | NULL                 | SMTP                     |
| `ServerName`             | NVARCHAR(50) | Name of the mail server              | NULL                 | mail.example.com         |
| `Port`                   | INT           | Port number for the mail server      | NULL                 | 587                      |
| `Username`               | NVARCHAR(50) | Username for authentication          | NULL                 | user                     |
| `SSLEnabled`             | BIT           | Indicates if SSL is enabled          | NULL                 | 1                        |
| `collect_date`           | DATETIME      | Date and time of data collection     | NULL                 | 2024-03-06 20:00:00      |

### Indexes

- `ix_server_database_mail_information_sql_instance`: Clustered index on the `SQLInstance` column for faster lookup of SQL Instances.


### Script

- [server_database_mail_information](../scripts/server_database_mail_information.md)
