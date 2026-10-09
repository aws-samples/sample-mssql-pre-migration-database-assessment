# mpa.ConfirmDatabaseInterdependency

### Description
This stored procedure returns information about cross database object referencing. It can help to understand communication happening from a database level when planning a database migration. When executed, the procedure returns objects that are calling objects from other databases.

### Permissions needed
- db_owner

### Tables queried

- raw.database_direct_reference_information

### Parameters

| Parameter Name | Data Type | Description                   |
|-----------------|-----------|-------------------------------|
| `@SQLInstance`      | VARCHAR(100)       | SQL Instance where of database being evaluated   |
| `@DatabaseName`      | VARCHAR(100)   | Database Name being evaluated   |


## Usage

To execute the `mpa.ConfirmDatabaseInterdependency` stored procedure, follow these steps:

1. Open a SQL query window in your database management tool.
2. Use the following SQL command to call the procedure:

```sql
EXEC mpa.ConfirmDatabaseInterdependency @SQLInstance = 'SERVER001', @DatabaseName = 'AdventureWorks2016';
```


### Sample Results

| SQLInstance  |  referencing_database_name | referenced_server_name  | referenced_database_name  |  objects_in_use |
|---|---|---|---|---|
|EC2AMAZ-2I49TPN|ReportServer|< localserver >|master|[{"referencing_object_type":"SQL_STORED_PROCEDURE","referencing_object_name":"Get_sqlagent_job_status"}]|
|EC2AMAZ-2I49TPN|ReportServer|< localserver >|msdb|[{"referencing_object_type":"SQL_STORED_PROCEDURE","referencing_object_name":"Get_sqlagent_job_status"},{"referencing_object_type":"SQL_TRIGGER","referencing_object_name":"Schedule_DeleteAgentJob"}]|
