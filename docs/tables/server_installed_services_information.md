# server_installed_services_information

### Description

This table holds information about installed services on SQL Server instances.

### Schema

- raw

### Table Columns

| Column Name                  | Data Type    | Description                                   | Constraints     | Example Values          |
|------------------------------|--------------|-----------------------------------------------|-----------------|-------------------------|
| `SQLInstance`                | VARCHAR(50)  | SQL Server instance name                       | NULL           | ServerA                 |
| `PhysicalServerName`         | VARCHAR(50)  | Name of the physical server                    | NULL           | ServerA                 |
| `SQLInstanceName`            | VARCHAR(50)  | Name of the SQL Server instance                | NULL           | MSSQLSERVER             |
| `SQLServerServices`          | VARCHAR(256) | List of SQL Server services installed          | NULL           | SQL Server, SQL Agent   |
| `CurrentServiceServiceStatus`| NVARCHAR(50) | Current status of the SQL Server services      | NULL           | Running                 |
| `collect_date`               | DATETIME     | Date and time of data collection               | NULL           | 2024-03-05 16:00:00     |

### Indexes

- `ix_server_installed_services_information_sql_instance`: Clustered index on the `SQLInstance` column for faster lookup of SQL Instances.

### Script

- [server_installed_services_information](../scripts/server_installed_services_information.md)
