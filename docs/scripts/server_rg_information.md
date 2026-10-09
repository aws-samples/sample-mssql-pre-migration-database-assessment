# server_rg_information.sql

## Description

This SQL Server script provides details and configurations of the Resource Governor. It checks if Resource Governor is enabled and retrieves information such as the classifier function, pool name, group name, importance, memory and CPU settings. The script utilizes system views such as `sys.resource_governor_configuration`, `sys.resource_governor_resource_pools`, and `sys.resource_governor_workload_groups`.

## Permissions needed

- `VIEW ANY DEFINITION`

## Scope

- Server

## Tables queried

- `sys.resource_governor_configuration`
- `sys.resource_governor_resource_pools`
- `sys.resource_governor_workload_groups`

## Columns

- `Hostname`
- `InstanceName`
- `is_enabled`
- `classifier`
- `pool_name`
- `group_name`
- `importance`
- `request_max_memory_grant_percent`
- `request_max_cpu_time_sec`
- `min_memory_percent`
- `max_memory_percent`
- `min_cpu_percent`
- `max_cpu_percent`
- `collect_date`

## Sample Results

| Hostname | InstanceName | is_enabled | classifier | pool_name | group_name | importance | request_max_memory_grant_percent | request_max_cpu_time_sec | min_memory_percent | max_memory_percent | min_cpu_percent | max_cpu_percent | collect_date          |
|----------|--------------|------------|------------|-----------|------------|------------|---------------------------------|--------------------------|--------------------|--------------------|-----------------|-----------------|-----------------------|
| ServerName | MSQLSERVER  | 1          | Classifier1 | Pool1     | Group1     | 1          | 50                              | 60                       | 10                 | 90                 | 20              | 80              | 2024-03-07 10:30:00  |
| ServerName | MSQLSERVER  | 1          | Classifier1 | Pool2     | Group2     | 2          | 60                              | 70                       | 20                 | 80                 | 30              | 70              | 2024-03-07 10:31:00  |
