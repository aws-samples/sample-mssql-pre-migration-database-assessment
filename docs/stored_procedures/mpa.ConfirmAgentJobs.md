# mpa.ConfirmAgentJobs

### Description

The purpose of this stored procedure is to generate a list of SQL Server Agent Jobs that are mapped to one or multiple databases that were listed as part of the Application being assessed.


### Permissions needed

- db_owner



### Tables queried

- dbo.vw_database_agent_job_information
- raw.server_proxy_agent_information
- mpa.master_applications
- mpa.master_databases

## Parameters

| Parameter Name  | Data Type   | Description                                     |
|-----------------|-------------|-------------------------------------------------|
| `@ApplicationName`    | varchar(100) | Input parameter representing the name of the application. |
| `@Environment`    | varchar(50) | Input parameter representing the environment of which you are trying to get the jobs. |


## Usage

To execute the `mpa.ConfirmAgentJobs` stored procedure, follow these steps:

1. Open a SQL query window in your database management tool.
2. Use the following SQL command to call the procedure:

```sql
EXEC mpa.ConfirmAgentJobs @ApplicationName = 'Sales Tool', @Environment = 'Development' ;
```

### Sample Results

| SQLInstance  | Environment | DatabaseName | Job Name | Job Enabled  | subsystems_used | ProxyName | CredentialIdentity | Migrate | ExtraNotes |
|--------------|-------------|--------------|----------|--------------|-----------------|-----------|--------------------|---------|------------|
| EC2AMAZ-2I49TPN | Development  |  dba_stats  | DBA Perfmon Cleanup | 1 | [{"subsystem":"TSQL"}]       |  |  |    |            |
