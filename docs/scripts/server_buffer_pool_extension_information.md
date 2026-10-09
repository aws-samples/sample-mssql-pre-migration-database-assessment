# server_buffer_pool_extension_information.sql

### Description

This script returns a list of Buffer Pool extension configured on the SQL Instance

### Permissions needed

-  VIEW SERVER STATE

### Scope
 - Server

### Tables queried

- sys.dm_os_buffer_pool_extension_configuration

#### Columns
- SQLInstance
- collect_date


### AwsDatabaseAssessment Table Name

- raw.server_buffer_pool_extension_information


### Sample Results

| SQLInstance  |  path | file_id  | state  |  state_description | current_size_in_kb | collect_date |
|---|---|---|---|---|---|---|
|AOAG-NODE-1|T:\Temp\BP_Extension.BPE|0|5|BUFFER POOL EXTENSION CLEAN PAGE CACHING ENABLED|20971520|2023-03-09 14:19:10.007|
