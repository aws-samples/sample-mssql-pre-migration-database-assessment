# database_crl_information.sql

### Description
This script returns any CLR objects found in any given database. This script helps when evaluating a source database to run on RDS for SQL Server.

### Permissions needed
- Requires membership in the public role of the user database

### Scope
 - Database level

### Tables queried

- sys.assembly_modules
- sys.assemblies
- sys.objects

#### Columns
- SQLInstance
- DatabaseName
- SchemaName
- ObjectName
- AssemblyName
- AssemblyClass
- AssemblyMethod
- PermissionSetDesc
- TypeDesc
- collect_date

### AwsDatabaseAssessment Table Name

- raw.database_crl_information


### Sample Results

| SQLInstance  |  DatabaseName | SchemaName  | ObjectName  |  AssemblyName | AssemblyClass | AssemblyMethod | PermissionSetDesc |TypeDesc | collect_date|
|---|---|---|---|---|---|---|---|---|---|
|AOAG-NODE-1|SSISDB|internal|get_execution_perf_counters|ISSERVER|Microsoft.SqlServer.IntegrationServices.Server.ExecPerfCounterApi|GetExecPerfCounters|UNSAFE_ACCESS|CLR_TABLE_VALUED_FUNCTION|2022-12-07 10:51:32.733|
|AOAG-NODE-1|SSISDB|internal|deploy_project_internal|ISSERVER|Microsoft.SqlServer.IntegrationServices.Server.ServerApi|DeployProjectInternal|UNSAFE_ACCESS|CLR_STORED_PROCEDURE|2022-12-07 10:51:32.733|
