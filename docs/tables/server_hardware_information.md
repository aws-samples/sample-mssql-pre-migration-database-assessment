# server_hardware_information

### Description

This table contains information about the hardware configuration of SQL Server instances.

### Schema

- raw

### Table Columns

| Column Name               | Data Type         | Description                                | Constraints         | Example Values           |
|---------------------------|-------------------|--------------------------------------------|----------------------|--------------------------|
| `SQLInstance`             | VARCHAR(50)       | SQL Server instance name                   | NULL                 | ServerA                  |
| `LogicalCPUCount`         | SMALLINT          | Number of logical CPUs                     | NULL                 | 8                        |
| `SchedulerCount`          | SMALLINT          | Number of schedulers                       | NULL                 | 16                       |
| `HyperthreadRatio`        | SMALLINT          | Hyperthread ratio                          | NULL                 | 1                        |
| `PhysicalCPUCount`        | SMALLINT          | Number of physical CPUs                    | NULL                 | 4                        |
| `PhysicalMemoryMB`        | DECIMAL(10, 2)    | Total physical memory in MB                | NULL                 | 8192.00                  |
| `CommittedMemoryMB`       | DECIMAL(10, 2)    | Committed memory in MB                     | NULL                 | 4096.00                  |
| `CommittedTargetMemoryMB` | DECIMAL(10, 2)    | Committed target memory in MB              | NULL                 | 6144.00                  |
| `MaxWorkersCount`         | SMALLINT          | Maximum worker thread count                | NULL                 | 1024                     |
| `AffinityType`            | NVARCHAR(50)      | Affinity type                              | NULL                 | MASK                     |
| `SQLServerStartTime`      | DATETIME          | Start time of SQL Server instance          | NULL                 | 2024-03-05 08:00:00      |
| `SQLServerUpTimeHrs`      | INT               | Up time of SQL Server instance in hours    | NULL                 | 24                       |
| `VirtualMachineType`      | NVARCHAR(50)      | Type of virtual machine                    | NULL                 | Hyper-V                  |
| `collect_date`            | DATETIME          | Date and time of data collection           | NULL                 | 2024-03-05 10:00:00      |

### Indexes

- `ix_hardware_information_sql_instance`: Clustered index on the `SQLInstance` column for faster lookup of SQL Instances.


### Script

- [server_hardware_information](../scripts/server_hardware_information.md)
