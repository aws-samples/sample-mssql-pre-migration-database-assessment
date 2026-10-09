# server_general_information

### Description

This table holds information about each SQL Server Instance being assessed.


### Schema

- raw


### Table Columns

| Column Name                 | Data Type       | Description                              | Constraints | Example Values        |
|-----------------------------|-----------------|------------------------------------------|-------------|-----------------------|
| `SQLInstance`               | VARCHAR(50)     | SQL Server instance name                 | NULL        | ServerA|
| `InstallDate`               | DATETIME        | Installation date of SQL Server         | NULL        | 2023-09-09 14:30:00 |
| `SQLServerEdition`          | NVARCHAR(50)   | SQL Server edition                       | NULL        | Developer Edition (64-bit)|
| `ProductLevel`              | NVARCHAR(50)   | SQL Server product level (e.g., RTM)    | NULL        | RTM |
| `ProductUpdateLevel`        | NVARCHAR(50)   | SQL Server product update level         | NULL        | NULL |
| `Collation`                 | NVARCHAR(50)   | Database collation                      | NULL        | SQL_Latin1_General_CP1_CI_AS |
| `ProductBuildLevel`         | NVARCHAR(50)   | SQL Server product build level          | NULL        | 15.0.2000.5|
| `SQLServerMajorVersion`     | NVARCHAR(50)   | SQL Server major version                 | NULL        | SQL Server 2019|
| `IsClustered`               | VARCHAR(5)      | Indicates if SQL Server is clustered    | NULL        | 0  |
| `IsHadrEnabled`             | VARCHAR(5)      | Indicates if High Availability and Disaster Recovery (HADR) is enabled | NULL | 1|
| `IsPolyBaseInstalled`       | VARCHAR(5)      | Indicates if PolyBase is installed      | NULL        | 0|
| `OSVersion`                 | VARCHAR(100)    | Operating system version                 | NULL        |Windows Server 2019 Datacenter 10.0 <X64\> (Build 17763: ) (Hypervisor)|
| `collect_date`              | DATETIME        | Date and time of data collection        | NULL        | 2023-09-09 10:00:00 |

### Indexes

- `ix_server_general_information_sql_instance`: Index on the `SQLInstance` column for faster lookup of SQL Instances.

### Script

- [server_general_information](../scripts/server_general_information.md)
