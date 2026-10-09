# mpa.ConfirmSSRSReports

### Description

The purpose of this stored procedure is to specifically identify SSRS Reports that any given instance being assessed may have.


### Permissions needed
- db_owner



### Tables queried

- raw.database_ssrs_reports_information

## Parameterss

| Parameter Name  | Data Type   | Description                                     |
|-----------------|-------------|-------------------------------------------------|
| `@SQLInstance`    | varchar(50) | Input parameter representing the SQL Server instance name. |


## Usage

To execute the `mpa.ConfirmSSRSReports` stored procedure, follow these steps:

1. Open a SQL query window in your database management tool.
2. Use the following SQL command to call the procedure:

```sql
EXEC mpa.ConfirmSSRSReports @SQLInstance = 'SERVER001';
```

### Sample Results

| SQLInstance     | TypeName | Path | Name | CreatedBy |
|-----------------|--------------|--------------|----------|----------|
| SERVER001      | Folder |  /Billing |  Billing | EC2AMAZ-2I49TPN\Administrator |
| SERVER001      | Image |  /Report Parts/Tablix2 |  Tablix2 | EC2AMAZ-2I49TPN\Administrator |
| SERVER001      | Report |  /Trades |  Trades | EC2AMAZ-2I49TPN\Administrator |
