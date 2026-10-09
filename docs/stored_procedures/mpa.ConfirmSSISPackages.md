# mpa.ConfirmSSISPackages

### Description
This stored procedure returns information about SSIS Packages found in the instance, and if they have components not supported for RDS.

### Permissions needed
- db_owner

### Tables queried

- dbo.vw_ssis_package_information

### Parameters

| Parameter Name | Data Type | Description                   |
|-----------------|-----------|-------------------------------|
| `@SQLInstance`      | VARCHAR(50)       | SQL Instance where of database being evaluated   |


## Usage

To execute the `mpa.ConfirmSSISPackages` stored procedure, follow these steps:

1. Open a SQL query window in your database management tool.
2. Use the following SQL command to call the procedure:

```sql
EXEC mpa.ConfirmSSISPackages @SQLInstance = 'EC2AMAZ-2I49TPN'
```


### Sample Results

| SQLInstance  |  Root Folder | Full Path  | PackageName  |  Description | Package Deployment Type |  RDSNonSupportedComponents | Migrate | Notes |
|---|---|---|---|---|---|---|---|---|
|EC2AMAZ-2I49TPN|OMBI|/OMBI|AgreementDimLoad1|Package that loads data to Agreement Dimension| Deployed in MSDB | [{"TaskType":"Microsoft.FileSystemTask"},{"ConnectionType":"FILE"},{"ConnectionType":"FLATFILE"}] | | |
|EC2AMAZ-2I49TPN|OMBI|/OMBI|OMBI_Abs_Act_Percentages|Package that calculates percentages| Deployed in MSDB | [{"ConnectionType":"FLATFILE"}]
 | | |
