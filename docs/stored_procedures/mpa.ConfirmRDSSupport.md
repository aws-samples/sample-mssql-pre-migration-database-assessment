# mpa.ConfirmRDSSupport

### Description

The purpose of this stored procedure is to validate SQL Server features that are being used in the environment, and may present a challenge for migration to Amazon RDS for SQL Server. Several of the limitations for RDS for SQL Server are validated.


### Permissions needed
- db_owner



### Tables queried

- raw.server_agent_jobs_information
- raw.server_general_information
- raw.server_configuration_in_use
- raw.database_general_information
- raw.server_replication_information
- raw.server_tcp_endpoints_information
- raw.server_logshipping_information
- raw.server_buffer_pool_extension_information
- raw.server_configuration_in_use
- raw.server_rg_information
- raw.server_maintence_plan_information
- raw.server_pbm_information
- raw.server_db_snapshot_information
- raw.server_trigger_information
- raw.database_size_information
- dbo.sql_server_extended_support_list


## Parameters


| Parameter Name  | Data Type   | Description                                     |
|-----------------|-------------|-------------------------------------------------|
| `@SQLInstance`    | varchar(50) | Input parameter representing the SQL Server instance name. |


## Usage

To execute the `mpa.ConfirmRDSSupport` stored procedure, follow these steps:

1. Open a SQL query window in your database management tool.
2. Use the following SQL command to call the procedure:

```sql
EXEC mpa.ConfirmRDSSupport @SQLInstance = 'EC2AMAZ-2I49TPN';
```

### Sample Results

| SQLInstance | ResourceGovernor | MaintenancePlans | PolicyBasedManagement | DatabaseSnapshots | ServerTriggers  | XPCmdShell | BufferPoolExtension | StretchDatabase|ServiceBrokerEnpoints| LogShipping|Replication| TCPEndpoints| Polybase| MachineLearningServices|DataQualityServices|PerformanceDataCollector|CLRSupport|StorageSize|VersionSupport|
|----------------|--|--|--|-----|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|
| EC2AMAZ-2I49TPN  | 0| 0 | 0  | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |0|0|0|
