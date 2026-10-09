# database_inmemory_information.sql

### Description

Script to check if database is using InMemory feature, will list all tables using inMemory.

### Permissions needed
- All rows are returned if you have VIEW DATABASE STATE permission on the current database. Otherwise, an empty rowset is returned.
- If you do not have VIEW DATABASE permission, all columns will be returned for rows in tables that you have SELECT permission on.

### Scope
 - Database

### Tables queried

- sys.dm_db_xtp_table_memory_stats
- sys.tables

#### Columns
- SQLInstance
- DatabaseName
- SchemaName
- TableName
- durability_desc
- create_date
- modify_date
- collect_date


### AwsDatabaseAssessment Table Name

- raw.database_inmemory_information


### Sample Results

| SQLInstance  |  DatabaseName | SchemaName | TableName  | durability_desc  |  create_date | modify_date | collect_date |
|---|---|---|---|---|---|---|---|
|AOAG-NODE-1|AdventureWorks2016|dbo|InInMemoryExample|SCHEMA_AND_DATA|2022-12-12 10:32:50.040|2022-12-12 10:32:50.040|2022-12-12 10:38:02.710|
