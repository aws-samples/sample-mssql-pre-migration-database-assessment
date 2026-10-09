# mpa.ConfirmSPConfigure

### Description

The purpose of this stored procedure is to specifically identify non-default configurations of SQL Server's sp_configure settings. These settings play a crucial role in configuring various aspects of SQL Server's behavior, and identifying non-default values can be essential for assessing server configurations.


### Permissions needed
- db_owner



### Tables queried

- dbo.vw_logins_and_users_instance
- raw.database_user_permissions
- dbo.logins_exclusion_list

## Parameters

| Parameter Name  | Data Type   | Description                                     |
|-----------------|-------------|-------------------------------------------------|
| `@SQLInstance`    | varchar(50) | Input parameter representing the SQL Server instance name. |


## Usage

To execute the `mpa.ConfirmSPConfigure` stored procedure, follow these steps:

1. Open a SQL query window in your database management tool.
2. Use the following SQL command to call the procedure:

```sql
EXEC mpa.ConfirmDatabaseUsers @SQLInstance = 'SERVER001';
```

### Sample Results

| SQLInstance     | ConfigurationName | DefaultValue | InUseValue |
|-----------------|--------------|--------------|----------|
| SQLServer1      | max degree of parallelism         | 2        | 5  |
