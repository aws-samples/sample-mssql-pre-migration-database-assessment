# server_configuration_in_use.sql

### Description

Script to retrieve configuration (sp_configure) from the instance.

### Permissions needed

- Requires membership in the public role.

### Scope

- Server

### Tables queried

- sys.configurations

#### Columns
- SQLInstance
- ConfigurationName
- State
- collect_date


### AwsDatabaseAssessment Table Name

- raw.server_configuration_in_use


### Sample Results

| SQLInstance  |  ConfigurationName | State  | collect_date |
|---|---|---|---|
|AOAG-NODE-1|recovery interval (min)|0|2022-12-07 13:01:55.997|
|AOAG-NODE-1|allow updates|0|2022-12-07 13:01:55.997|
|AOAG-NODE-1|user connections|0|2022-12-07 13:01:55.997|
|AOAG-NODE-1|locks|0|2022-12-07 13:01:55.997|
|AOAG-NODE-1|nested triggers|1|2022-12-07 13:01:55.997|
