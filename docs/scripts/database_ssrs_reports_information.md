# database_ssrs_reports_information.sql

### Description

Script to collect reporting services information

### Permissions needed

- db_datareader on the report server database

### Scope

- Database

### Tables queried

- dbo.Catalog
- dbo.Users

#### Columns
- SQLInstance
- ItemID
- Path
- Name
- ParentID
- TypeName
- LinkSourceID
- Description
- Hidden
- CreatedBy
- CreationDate
- ModifiedBy
- ModifiedDate
- collect_date


### AwsDatabaseAssessment Table Name

- raw.database_ssrs_reports_information


### Sample Results

| SQLInstance  |  ItemID | Path  | Name  |  ParentID | TypeName | LinkSourceID | Description | Hidden | CreatedBy | CreationDate | ModifiedBy | ModifiedDate | collect_date |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
 AOAG-NODE-1| 2FB3A2D5-348B-428B-81D2-97F50F373FAC|||NULL|Folder|NULL|	NULL|	NULL|NT AUTHORITY\SYSTEM|2022-12-13 13:37:28.870|CORP\Admin|NULL|2022-12-13 14:28:39.160|
  AOAG-NODE-1| 8E13E3A4-D15D-4B98-A737-2AFD367F7B2C|	/68f0607b-9378-4bbb-9e70-4da3d7d66838|	System Resources|	2FB3A2D5-348B-428B-81D2-97F50F373FAC| Folder|	NULL|	NULL	|NULL	|NT AUTHORITY\SYSTEM	|2022-12-13 13:37:41.963|	NT AUTHORITY\SYSTEM	|2022-12-13 13:37:58.317|	2022-12-13 14:28:39.160|
   AOAG-NODE-1|	1E287064-285E-4DEE-8914-67B29BD70665	|/BikeStore |	BikeStore	|2FB3A2D5-348B-428B-81D2-97F50F373FAC	|Data Source |	NULL	|NULL	|0	|CORP\Admin|	2022-12-13 13:55:48.600|	CORP\Admin	|NULL	|2022-12-13 14:28:39.160|
   AOAG-NODE-1|F6CFE394-BB5B-47FE-B8D9-B03CA0F0C466|	/Customer Orders|	Customer Orders|	2FB3A2D5-348B-428B-81D2-97F50F373FAC|	Report	|NULL	|NULL|	0|	CORP\Admin|	2022-12-13 13:57:16.563	|CORP\Admin	|NULL|2022-12-13 14:28:39.160|
