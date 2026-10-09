# server_linked_server_information.sql

## Description

This SQL Server script collects linked servers configured in the instance. It retrieves details such as SQL instance name, linked server name, provider name, product, data source, provider string, location, category, and collection date using the stored procedure `sp_linkedservers`.

## Permissions needed

- `public`

## Scope

- Server

## Columns

- `SQLInstance`
- `LinkedServerName`
- `ProviderName`
- `Product`
- `DataSource`
- `ProviderString`
- `Location`
- `Category`
- `collect_date`

## Sample Results

| SQLInstance | LinkedServerName | ProviderName   | Product | DataSource | ProviderString | Location | Category | collect_date          |
|-------------|------------------|----------------|---------|------------|----------------|----------|----------|-----------------------|
| ServerName  | LinkedServer1    | SQL Server     |         | ServerName |                |          |          | 2024-03-07 10:30:00   |
| ServerName  | LinkedServer2    | SQL Server     |         | ServerName |                |          |          | 2024-03-07 10:31:00   |
