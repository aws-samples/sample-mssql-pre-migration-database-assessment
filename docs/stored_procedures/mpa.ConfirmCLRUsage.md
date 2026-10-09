# mpa.ConfirmCLRUsage

### Description

The purpose of this stored procedure is to generate a list CLR objects found in the databases that are part of the application to be assessed.


### Permissions needed

- db_owner



### Tables queried

- dbo.vw_database_general_information
- raw.database_clr_information
- mpa.master_applications
- mpa.master_databases

## Parameters

| Parameter Name  | Data Type   | Description                                     |
|-----------------|-------------|-------------------------------------------------|
| `@ApplicationName`    | varchar(100) | Input parameter representing the name of the application. |
| `@Environment`    | varchar(50) | Input parameter representing the environment of which you are trying to get the CLR's. |


## Usage

To execute the `mpa.ConfirmCLRUsage` stored procedure, follow these steps:

1. Open a SQL query window in your database management tool.
2. Use the following SQL command to call the procedure:

```sql
EXEC mpa.ConfirmCLRUsage @ApplicationName = 'Sales Tool', @Environment = 'Development' ;
```

### Sample Results

| SQLInstance  | DatabaseName | SchemaName | ObjectName | PermissionSetDesc  | TypeDesc | Migrate | ExtraNotes |
|--------------|-------------|--------------|----------|--------------|-----------------|-----------|-----------------|
| EC2AMAZ-2I49TPN | dbJarvisFunctions  |  Pub  | Pub_Fn_ConvertGregorianTo_CLR | EXTERNAL_ACCESS |CLR_SCALAR_FUNCTION  | ||
| EC2AMAZ-2I49TPN | dbJarvisFunctions  |  Pub  | Pub_Fn_DynamicQueryGetScalarValue | EXTERNAL_ACCESS |CLR_TABLE_VALUED_FUNCTION  | ||
