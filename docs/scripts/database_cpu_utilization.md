# database_cpu_information.sql

### Description
This script returns the accumulated CPU utilization per database. This script helps when evaluating RDS instance sizes for RDS for SQL Server.
It is important to mention the data retrieved by this script is the one accumulated since the last SQL Server restart or since the last cache clearance.

### Permissions needed
- On SQL Server and SQL Managed Instance, requires VIEW SERVER STATE permission.

### Scope
 - Database level

### Tables queried

- sys.dm_exec_query_stats
- sys.dm_exec_plan_attributes

#### Columns
- SQLInstance
- CPURank
- DatabaseName
- CPUTimeMiliSecond
- CPUPercent
- collect_date


### AwsDatabaseAssessment Table Name

- raw.database_cpu_information


### Sample Results

| SQLInstance  |  CPURank | DatabaseName  | CPUTimeMiliSecond  |  CPUPercent | collect_date |
|---|---|---|---|---|---|
|AOAG-NODE-1|1|master|1323649|48.94|2022-12-07 11:29:58.667|
|AOAG-NODE-1|1|msdb|1263531|46.72|2022-12-07 11:29:58.667|
