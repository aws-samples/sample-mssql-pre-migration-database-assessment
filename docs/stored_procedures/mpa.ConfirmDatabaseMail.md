# mpa.ConfirmDatabaseMail

### Description

The purpose of this stored procedure is to generate a list of Database Mail profiles and accounts with a specific SQL Server instance (@SQLInstance). This is used for planning the migration of a SQL Server database, and understand which Database Mail profiles needs to be moved.


### Permissions needed

- db_owner



### Tables queried

- raw.server_database_mail_information

## Parameters

| Parameter Name  | Data Type   | Description                                     |
|-----------------|-------------|-------------------------------------------------|
| `@SQLInstance`    | varchar(50) | Input parameter representing the SQL Server instance name. |


## Usage

To execute the `mpa.ConfirmDatabaseMail` stored procedure, follow these steps:

1. Open a SQL query window in your database management tool.
2. Use the following SQL command to call the procedure:

```sql
EXEC mpa.ConfirmDatabaseMail @SQLInstance = 'SERVER001';
```

### Sample Results

| SQLInstance      | ProfileName | ProfileDescription | AccountName | EmailAddress                    | DisplayName   | ServerType | ServerName            | Port | Migrate | ExtraNotes |
|-------------------|-------------|---------------------|-------------|---------------------------------|---------------|------------|------------------------|------|---------|------------|
| EC2AMAZ-2I49TPN   | Profile001  |                     | Account001  | dba-alerts@example.com          | DBA Team      | SMTP       | smtp.example.com       | 25   |         |            |
