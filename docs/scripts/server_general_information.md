# server_general_information.sql

### Description

Script to retrieve SQL Instance general information such as build levels, version, edition, etc..

### Permissions needed

- public role on master database
- VIEW SERVER PERFORMANCE

### Scope

- Server

### Tables queried

- sys.server_principals

#### Columns
- SQLInstance
- InstallDate
- SQLServerStartTime
- SQLServerEdition
- ProductLevel
- ProductUpdateLevel
- Collation
- ProductBuildLevel
- SQLServerMajorVersion
- IsClustered
- IsHadrEnabled
- IsPolyBaseInstalled
- OSVersion
- collect_date


### AwsDatabaseAssessment Table Name

- raw.server_general_information


### Sample Results

| SQLInstance  |  InstallDate | SQLServerStartTime | SQLServerEdition  | ProductLevel  |  ProductUpdateLevel | Collation | ProductBuildLevel | SQLServerMajorVersion | IsClustered | IsHadrEnabled | IsPolyBaseInstalled | OSVersion | collect_date |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
|AOAG-NODE-1|2022-05-19 09:55:46.350|2022-05-21 09:55:46.350|Developer Edition (64-bit)|RTM|NULL|SQL_Latin1_General_CP1_CI_AS|15.0.2000.5|SQL Server 2019|0|1|0|Windows Server 2019 Datacenter 10.0 <X64\> (Build 17763: ) (Hypervisor) |2023-03-13 15:44:46.580|
