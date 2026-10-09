# server_proxy_agent_information

### Description

This table holds information about SQL Server Agent proxies on SQL Server instances.

### Schema

- raw

### Table Columns

| Column Name          | Data Type    | Description                              | Constraints        | Example Values          |
|----------------------|--------------|------------------------------------------|--------------------|-------------------------|
| `SQLInstance`        | VARCHAR(50)  | SQL Server instance name                  | NULL              | ServerA                 |
| `ProxyID`            | INT          | ID of the SQL Server Agent proxy          | NULL              | 1                       |
| `ProxyName`          | NVARCHAR(50) | Name of the SQL Server Agent proxy        | NULL              | SQLProxy                |
| `CredentialID`       | NVARCHAR(20) | ID of the credential associated with the proxy | NULL         | 123                     |
| `CredentialIdentity` | NVARCHAR(100)| Identity associated with the credential   | NULL              | Domain\ProxyUser        |
| `JobStepID`          | INT          | ID of the SQL Server Agent job step       | NULL              | 1                       |
| `StepName`           | NVARCHAR(128)| Name of the SQL Server Agent job step     | NULL              | Step1                   |
| `JobName`            | NVARCHAR(128)| Name of the SQL Server Agent job          | NULL              | BackupJob               |
| `collect_date`       | DATETIME     | Date and time of data collection          | NULL              | 2024-03-05 15:30:00     |

### Indexes

- `ix_server_proxy_agent_information_sql_instance`: Clustered index on the `SQLInstance` column for faster lookup of SQL Instances.

### Script

- [server_proxy_agent_information](../scripts/server_proxy_agent_information.md)
