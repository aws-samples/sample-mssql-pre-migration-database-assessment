# mpa.ConfirmCredentials

### Description

The purpose of this stored procedure is to generate a list Server Credentials objects found in the server where there are databases belonging to the application being assessed.


### Permissions needed

- db_owner



### Tables queried

- dbo.vw_logins_and_users_instance
- raw.server_credential_information
- mpa.master_applications
- mpa.master_databases

## Parameters

| Parameter Name  | Data Type   | Description                                     |
|-----------------|-------------|-------------------------------------------------|
| `@ApplicationName`    | varchar(100) | Input parameter representing the name of the application. |
| `@Environment`    | varchar(50) | Input parameter representing the environment of which you are trying to get the credentials. |


## Usage

To execute the `mpa.ConfirmCredentials` stored procedure, follow these steps:

1. Open a SQL query window in your database management tool.
2. Use the following SQL command to call the procedure:

```sql
EXEC mpa.ConfirmCredentials @ApplicationName = 'Sales Tool', @Environment = 'Development' ;
```

### Sample Results

| SQLInstance  | CredentialName | CredentialIdentity | Migrate | ExtraNotes |
|--------------|-------------|--------------|----------|--------------|
| EC2AMAZ-2I49TPN | SSISCreds  |  CORP\ssisaccount  ||  |
