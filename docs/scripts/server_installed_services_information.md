# server_installed_services_information.md

## Description

This SQL Server script checks for installed SQL Server services and retrieves their status. It identifies services such as SQL Server, SQL Server Agent, SQL Browser, Integration Service, Reporting Service, Analysis Service, and Full Text Search Service.

## Permissions needed

- `sysadmin`

## Scope

- Server

## Columns

- `SQLInstance`
- `PhysicalServerName`
- `SQLInstanceName`
- `SQLServerServices`
- `CurrentServiceServiceStatus`
- `collect_date`

## Sample Results

| SQLInstance | PhysicalServerName | SQLInstanceName | SQLServerServices        | CurrentServiceServiceStatus | collect_date          |
|-------------|--------------------|-----------------|--------------------------|-----------------------------|-----------------------|
| ServerName  | PhysicalServerName | SQLInstanceName | SQL Server Service       | Running                     | 2024-03-07 10:30:00   |
| ServerName  | PhysicalServerName | SQLInstanceName | SQL Server Agent Service | Running                     | 2024-03-07 10:31:00   |
