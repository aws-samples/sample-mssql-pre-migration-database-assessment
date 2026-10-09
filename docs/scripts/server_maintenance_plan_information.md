# server_maintenance_plan_information.sql

## Description

This SQL Server script lists all SQL Server Maintenance Plans. It retrieves details such as maintenance plan name, description, owner, subplan name, subplan description, job name, job description, task name, database name, enabled status, and collection date. The script queries the system tables `msdb.dbo.sysmaintplan_plans`, `msdb.dbo.sysmaintplan_subplans`, `msdb.dbo.sysjobs`, and `msdb.dbo.sysssispackages`.

## Permissions needed

- `db_datareader` on the `msdb` database

## Scope

- Server

## Tables queried

- `msdb.dbo.sysmaintplan_plans`
- `msdb.dbo.sysmaintplan_subplans`
- `msdb.dbo.sysjobs`
- `msdb.dbo.sysssispackages`

## Columns

- `SQLInstance`
- `MaintenancePlan`
- `Description`
- `PlanOwner`
- `SubplanName`
- `SubplanDescription`
- `JobName`
- `JobDescription`
- `Enabled`
- `TaskName`
- `DatabaseName`
- `collect_date`

## Sample Results

| SQLInstance | MaintenancePlan | Description | PlanOwner | SubplanName | SubplanDescription | JobName | JobDescription | Enabled | TaskName | DatabaseName | collect_date          |
|-------------|-----------------|-------------|-----------|-------------|--------------------|---------|----------------|---------|----------|--------------|-----------------------|
| ServerName  | Plan1           | Desc1       | Owner1    | Subplan1    | SubplanDesc1       | Job1    | JobDesc1       | 1       | Task1    | Database1    | 2024-03-07 10:30:00  |
| ServerName  | Plan2           | Desc2       | Owner2    | Subplan2    | SubplanDesc2       | Job2    | JobDesc2       | 0       | Task2    | Database2    | 2024-03-07 10:31:00  |
