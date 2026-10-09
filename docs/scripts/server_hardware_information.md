# server_hardware_information.sql

## Description

This script collects hardware information about the SQL Server instance, including CPU count, scheduler count, hyperthread ratio, physical memory, committed memory, maximum workers count, affinity type, SQL Server start time, SQL Server uptime, and virtual machine type.

## Permissions needed

- `VIEW SERVER STATE`

## Scope

- Server

## Sample Results

| SQLInstance | LogicalCPUCount | SchedulerCount | HyperthreadRatio | PhysicalCPUCount | PhysicalMemoryMB | CommittedMemoryMB | CommittedTargetMemoryMB | MaxWorkersCount | AffinityType | SQLServerStartTime | SQLServerUpTimeHrs | VirtualMachineType | collect_date         |
|-------------|-----------------|----------------|------------------|------------------|------------------|-------------------|-------------------------|-----------------|--------------|--------------------|--------------------|---------------------|----------------------|
| ServerName  | 8               | 8              | 1                | 8                | 32768            | 4996              | 4996                    | 1024            | NODE         | 2024-03-07 10:00:00| 5                  | NULL                | 2024-03-07 10:30:00  |
