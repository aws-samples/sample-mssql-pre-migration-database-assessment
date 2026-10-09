# mpa.GeneralInformation

### Description

The purpose of this stored procedure is to generate a list of important information about an application's database(s) to be migrated to the cloud.


### Permissions needed

- db_owner



### Tables queried

- raw.vw_database_general_information
- mpa.master_applications
- mpa.master_databases

## Parameters

| Parameter Name  | Data Type   | Description                                     |
|-----------------|-------------|-------------------------------------------------|
| `@ApplicationName`    | varchar(100) | Input parameter representing the name of the application. |
| `@Environment`    | varchar(50) | Input parameter representing the environment of which you are trying to get the information. |


## Usage

To execute the `mpa.GeneralInformation` stored procedure, follow these steps:

1. Open a SQL query window in your database management tool.
2. Use the following SQL command to call the procedure:

```sql
EXEC mpa.GeneralInformation @ApplicationName = 'Sales Tool', @Environment = 'Development' ;
```

### Sample Results

| ApplicationId | ApplicationName | Environment | AWS Account ID | AWS Account | SQLInstance        | DatabaseName | ServerCollation                   | DatabaseCollation               | TotalSizeMB | SQLServerMajorVersion | SQLServerEdition                   | SSRSDeployed | SSASDeployed | SSISDeployed | TimezoneConfiguration        | Tags | RDSRecommendedInstances                                      | DowngradeToStandardEdition | SCTReportValidated | RDSEndpointName | Migrate |
|---------------|-----------------|-------------|-----------------|--------------|---------------------|--------------|-----------------------------------|----------------------------------|-------------|-----------------------|------------------------------------|--------------|--------------|--------------|-----------------------------|------|-----------------------------------------------------------------|---------------------------|---------------------|------------------|---------|
| APP0001       | SalesERP        | DEV         |                 | SALES-ERP-0001-DEV | EC2AMAZ-2I49TPN     | DB001        | SQL_Latin1_General_CP1_CI_AS     | Persian_100_CI_AS               | 1600        | SQL Server 2019       | Developer Edition (64-bit)         | NO           | NO           | NO           | South Africa Standard Time |      | [{"instance_type":"db.r6g.large","vcpu":2,"memory":16}]           |                           |                   |                  | YES     |
| APP0001       | SalesERP        | DEV         |                 | SALES-ERP-0001-DEV | EC2AMAZ-2I49TPN     | DB002        | SQL_Latin1_General_CP1_CI_AS     | Latin1_General_CI_AS             | 1600        | SQL Server 2019       | Developer Edition (64-bit)         | NO           | NO           | NO           | South Africa Standard Time |      | [{"instance_type":"db.r6g.large","vcpu":2,"memory":16}]           |                           |                   |                  | YES     |
| APP0001       | SalesERP        | DEV         |                 | SALES-ERP-0001-DEV | EC2AMAZ-2I49TPN     | DB003        | SQL_Latin1_General_CP1_CI_AS     | SQL_Latin1_General_CP1_CI_AS    | 860488      | SQL Server 2019       | Developer Edition (64-bit)         | NO           | NO           | NO           | South Africa Standard Time |      | [{"instance_type":"db.r6g.large","vcpu":2,"memory":16}]           |                           |                   |                  | YES     |
