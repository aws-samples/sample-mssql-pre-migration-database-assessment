# dbo.FixSSIS_packages_connection_type_ssisdb

### Description

The purpose of this stored procedure is to clean-up two tables in the AwsDatabaseAssessment that are holding SSIS Package information. It cleans non-necessary information and make some adjustements on the data for better visualization. It runs as part of the ./LoadDatabase.ps1 script.


### Permissions needed
- db_owner



### Tables queried

- raw.ssis_packages_connection_type_ssisdb
- raw.ssis_packages_connection_type_msdb
- raw.database_general_information


## Usage

To execute the `dbo.FixSSIS_packages_connection_type_ssisdb` stored procedure, follow these steps:

1. Open a SQL query window in your database management tool.
2. Use the following SQL command to call the procedure:

```sql
EXEC dbo.FixSSIS_packages_connection_type_ssisdb;
```

### Sample Results

No result set is returned.
