# database_io_utilization.sql

### Description

Script to collect I/O utilization per database

### Permissions needed
- VIEW SERVER STATE

### Scope

 - Database

### Tables queried

- sys.dm_io_virtual_file_stats

#### Columns

- SQLInstance
- IORank
- DatabaseName
- TotalIOMB
- TotalIOPercent
- ReadIOMB
- ReadIOPercent
- WriteIOMB
- WriteIOPercent
- collect_date


### AwsDatabaseAssessment Table Name

- raw.database_io_utilization


### Sample Results

| SQLInstance  |  IORank | DatabaseName  | TotalIOMB  |  TotalIOPercent | ReadIOMB | ReadIOPercent | WriteIOMB | WriteIOPercent | collect_date |
|---|---|---|---|---|---|---|---|---|---|
|AOAG-NODE-1|1|AdventureWorks2016|23.00|23.23|23.00|23.47|0.00|0.00|2022-12-12 10:47:33.117|
|AOAG-NODE-1|2|AwsDatabaseAssessment|19.00|19.19|19.00|19.39|0.00|0.00|2022-12-12 10:47:33.117|
|AOAG-NODE-1|3|SSISDB|12.00|12.12|12.00|12.24|0.00|0.00|2022-12-12 10:47:33.117|
