# database_downgrade_to_standard.sql

### Description

Script to retrieve any features that could prevent a downgrade from SQL Server Enterprise to Standard Edition

### Permissions needed
- VIEW DATABASE STATE

### Scope
 - Database Level

### Tables queried

- sys.dm_db_persisted_sku_features

#### Columns
- SQLInstance
- DatabaseName
- FeatureName
- collect_date


### AwsDatabaseAssessment Table Name

- raw.database_downgrade_to_standard


### Sample Results

| SQLInstance | DatabaseName | FeatureName | collect_date |
|-----------|---|---|---|
|AOAG-NODE-1|AdventureWorks2016|Compression|2022-12-07 13:01:55.997|
|AOAG-NODE-1|AdventureWorks2016|Partitioning|2022-12-07 13:01:55.997|
