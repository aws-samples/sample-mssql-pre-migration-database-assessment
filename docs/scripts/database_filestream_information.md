# database_filestream_information.sql

### Description

Script to list databases with filestream enabled

### Permissions needed
- VIEW SERVER STATE

### Scope
 - Database

### Tables queried

- sys.database_filestream_options

#### Columns
- SQLInstance
- DatabaseName
- non_transacted_access
- non_transacted_access_desc
- directory_name
- collect_date


### AwsDatabaseAssessment Table Name

- raw.database_filestream_information


### Sample Results

| SQLInstance  |  DatabaseName | non_transacted_access  | non_transacted_access_desc  |  directory_name | collect_date |
|---|---|---|---|---|---|
|AOAG-NODE-1|AdventureWorks2016|2|FULL|SQL2014|2022-12-07 14:09:15.833|
