# dbo.spCleanUpAssessmentDatabase

### Description

The purpose of this stored procedure is to clean-up the raw schema. It runs as part of the ./LoadDatabase.ps1 script.


### Permissions needed
- db_owner



### Tables queried

- sys.schemas
- sys.tables


## Usage

To execute the `dbo.spCleanUpAssessmentDatabase` stored procedure, follow these steps:

1. Open a SQL query window in your database management tool.
2. Use the following SQL command to call the procedure:

```sql
EXEC dbo.spCleanUpAssessmentDatabase;
```

### Sample Results

No result set is returned.
