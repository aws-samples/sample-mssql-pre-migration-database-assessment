# dbo.vw_database_general_information

## Description

This view provides comprehensive information about databases and their associated SQL Server instances. It retrieves data from various tables including `raw.database_general_information`, `raw.database_size_information`, `raw.server_general_information`, `raw.database_cpu_utilization`, `raw.server_hardware_information`, `raw.server_installed_services_information`, `raw.server_timezone_information`, and `raw.database_io_utilization`. Details such as SQL instance, logical CPU count, committed memory, database name, database size, collation, read/write I/O percentage, SQL Server services deployment status, instance clustering status, HADR (High Availability and Disaster Recovery) enabled status, and more are included in the output.

## Schemas Touched

- dbo
- raw

## Permissions

This view requires appropriate permissions to access the following objects:
- [`raw.database_general_information`](../tables/database_general_information.md)
- [`raw.database_size_information`](../tables/database_size_information.md)
- [`raw.server_general_information`](../tables/server_general_information.md)
- [`raw.database_cpu_utilization`](../tables/database_cpu_utilization.md)
- [`raw.server_hardware_information`](../tables/server_hardware_information.md)
- [`raw.server_installed_services_information`](../tables/server_installed_services_information.md)
- [`raw.server_timezone_information`](../tables/server_timezone_information.md)
- [`raw.database_io_utilization`](../tables/database_io_utilization.md)

## Sample Results

Below is an example of the output you can expect from this view:

| SQLInstance  | Logical CPU Count | Committed Memory (MB) | Committed Target Memory (MB) | DatabaseName        | TotalSizeMB | AvailableSizeMB | UsedSizeMB | DatabaseCollation | ReadOnlyDatabase | RecoveryModel | IsDistributorDatabase | IsSubscriberDatabase | IsPublishedDatabase | SQLServerEdition | SQLServerMajorVersion | ProductBuildLevel | InstanceCollation | CPURank | CPUPercent | IORank | ReadIOPercentage | WriteIOPercentage | SSRSDeployed | SSASDeployed | SSISDeployed | IsClustered | IsHadrEnabled | TimezoneConfiguration |
|--------------|-------------------|-----------------------|------------------------------|---------------------|-------------|-----------------|------------|-------------------|------------------|---------------|----------------------|----------------------|---------------------|------------------|----------------------|-------------------|-------------------|---------|------------|--------|------------------|-------------------|--------------|--------------|--------------|-------------|---------------|-----------------------|
| SQLInstance1 | 8                 | 16384                 | 8192                         | AdventureWorks2016  | 1024        | 256             | 768        | SQL_Latin1_General_CP1_CI_AS | 0                | FULL          | 0                    | 0                    | 0                   | Enterprise Edition | 15                   | 1103              | SQL_Latin1_General_CP1_CI_AS | 1       | 40         | 2      | 60               | 40                | 1            | 0            | 1            | 0           | 1             | 'UTC'                 |
| SQLInstance2 | 16                | 32768                 | 16384                        | AdventureWorks2017  | 2048        | 512             | 1536       | Latin1_General_CI_AS | 0                | SIMPLE        | 0                    | 0                    | 0                   | Standard Edition  | 15                   | 2137              | Latin1_General_CI_AS | 1       | 60         | 1      | 70               | 30                | 0            | 1            | 1            | 1           | 0             | 'Europe/Paris'        |
