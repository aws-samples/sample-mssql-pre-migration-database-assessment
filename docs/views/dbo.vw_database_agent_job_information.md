# dbo.vw_database_agent_job_information

## Description

This view provides information about SQL Server Agent jobs associated with databases. It combines data from the `raw.database_general_information` and `raw.server_agent_jobs_information` tables. Details such as SQL instance, database name, job name, job step ID, job step name, step subsystem, and job enabled status are included in the output. Additionally, the view provides information about subsystems used in the job steps.

## Schemas Touched

- dbo
- raw

## Permissions

This view requires appropriate permissions to access the following objects:
- [`raw.database_general_information`](../tables/database_general_information.md)
- [`raw.server_agent_jobs_information`](../tables/server_agent_jobs_information.md)

## Sample Results

Below is an example of the output you can expect from this view:

| SQLInstance  | DatabaseName        | JobName       | JobStepId | JobStepName | StepSubsystem | JobEnabled  | SubsystemsUsed        |
|--------------|---------------------|---------------|-----------|--------------|---------------|------------|-----------------------|
| SQLInstance1 | AdventureWorks2016  | BackupJob     | 1         | Backup Step  | T-SQL         | 1          | [{"subsystem":"..."}] |
| SQLInstance2 | AdventureWorks2016  | MaintenanceJob| 1         | Maintenance  | PowerShell    | 1          | [{"subsystem":"..."}] |
