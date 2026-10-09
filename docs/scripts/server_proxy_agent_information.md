# server_proxy_agent_information.sql

## Description

This SQL Server script collects information about proxies and related jobs. It retrieves details such as proxy ID, proxy name, associated credential ID and identity, job step ID, step name, and job name from the system tables `msdb.dbo.sysproxies`, `master.sys.credentials`, `msdb.dbo.sysjobsteps`, and `msdb.dbo.sysjobs`.

## Permissions needed

- db_datareader on `msdb`

## Scope

- Server

## Tables queried

- `msdb.dbo.sysproxies`
- `master.sys.credentials`
- `msdb.dbo.sysjobsteps`
- `msdb.dbo.sysjobs`

## Columns

- `SQLInstance`
- `ProxyID`
- `ProxyName`
- `CredentialID`
- `CredentialIdentity`
- `JobStepID`
- `StepName`
- `JobName`
- `collect_date`

## Sample Results

| SQLInstance | ProxyID | ProxyName | CredentialID | CredentialIdentity | JobStepID | StepName | JobName | collect_date          |
|-------------|---------|-----------|--------------|--------------------|-----------|----------|---------|-----------------------|
| ServerName  | 1       | Proxy1    | 1            | User1              | 1         | Step1    | Job1    | 2024-03-07 10:30:00  |
| ServerName  | 2       | Proxy2    | 2            | User2              | 2         | Step2    | Job2    | 2024-03-07 10:31:00  |
