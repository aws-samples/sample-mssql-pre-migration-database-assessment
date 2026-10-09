# sql_server_extended_support_list

### Description

This table lists the lifecycle information for SQL Server from 2008 to SQL Server 2012. This table is used by [mpa.ConfirmRDSSupport](../stored_procedures/mpa.ConfirmRDSSupport.md) to validate the `VersionSupport` check. The lifecyle information has been extrated from the official Microsoft documentation: [Search Product and Services Lifecycle Information](https://learn.microsoft.com/en-us/lifecycle/products/)


### Schema

- dbo


### Table Columns

| Column Name             | Data Type   | Description                 | Constraints | Example Values  |
|-------------------------|-------------|-----------------------------|-------------|-----------------|
| `SQLServerVersion`      | VARCHAR(50) | SQL Server Version          | NULL        | SQL Server 2014 |
| `StartDate`             | DATE        | Release date of SQL Server  | NULL        | 2014-06-05      |
| `MainstreamEndDate`     | DATE        | Mainstream support date end | NULL        | 2019-07-05      |
| `ExtendedEndDate`       | DATE        | Extended support date end   | NULL        | 2024-07-09      |

### Indexes

- `ix_sql_server_extended_support_list`: Index on the `SQLServerVersion` column for faster lookup of SQL Instances.

### Script

- N/A
