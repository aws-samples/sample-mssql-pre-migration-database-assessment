# server_pbm_information.sql

## Description

This SQL Server script lists all Policy-Based Management (PBM) policies in the instance server. It retrieves information such as policy name, associated condition, facet, creation and modification dates, execution mode, and collection date. The script queries system tables `msdb.dbo.syspolicy_policies_internal` and `msdb.dbo.syspolicy_conditions`.

## Permissions needed

- `db_datareader` on the `msdb` database

## Scope

- Server

## Tables queried

- `msdb.dbo.syspolicy_policies_internal`
- `msdb.dbo.syspolicy_conditions`

## Columns

- `SQLInstance`
- `Policy`
- `Condition`
- `Facet`
- `Date_Created`
- `Date_Modified`
- `Execution_Mode`
- `collect_date`

## Sample Results

| SQLInstance | Policy      | Condition | Facet   | Date_Created        | Date_Modified       | Execution_Mode | collect_date          |
|-------------|-------------|-----------|---------|---------------------|---------------------|----------------|-----------------------|
| ServerName  | Policy1     | Condition1| Facet1  | 2024-03-07 10:30:00 | 2024-03-07 10:31:00 | OnDemand       | 2024-03-07 10:32:00   |
| ServerName  | Policy2     | Condition2| Facet2  | 2024-03-07 10:31:00 | 2024-03-07 10:32:00 | OnChangePrevent| 2024-03-07 10:33:00   |
