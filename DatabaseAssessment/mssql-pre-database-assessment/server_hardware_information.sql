/*
#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

*/

/*
Author: 		Marcos Freccia (mfreccia)
Date: 			29/11/2022
Description: 	Script to collect hardware information
Permission:     VIEW SERVER STATE

Author: 		Marcelo Fernandes (marcesl)
Date: 			03/04/2025
Description: 	adjusted for SQL 2008/2008R2
*/

DECLARE @SQLBuild DECIMAL(4,2) = 0,
        @STRSQL VARCHAR(MAX);
SELECT @SQLBuild = CAST(LEFT(CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(50)), 4) AS DECIMAL(4,2))
IF (@SQLBuild) > 10.50
BEGIN
    SET @STRSQL
        = 'SELECT @@SERVERNAME as SQLInstance,
		cpu_count AS [LogicalCPUCount], scheduler_count as SchedulerCount,
       hyperthread_ratio AS [HyperthreadRatio],
       cpu_count/hyperthread_ratio AS [PhysicalCPUCount],
       physical_memory_kb/1024 AS [PhysicalMemoryMB],
	   committed_kb/1024 AS [CommittedMemoryMB],
       committed_target_kb/1024 AS [CommittedTargetMemoryMB],
       max_workers_count AS [MaxWorkersCount],
	   affinity_type_desc AS [AffinityType],
       sqlserver_start_time AS [SQLServerStartTime],
	   DATEDIFF(hour, sqlserver_start_time, GETDATE()) AS [SQLServerUpTimeHrs],
	   virtual_machine_type_desc AS [VirtualMachineType]
	   ,getdate() as collect_date
FROM sys.dm_os_sys_info WITH (NOLOCK) OPTION (RECOMPILE);';
    EXEC (@STRSQL);
END;
ELSE IF (@SQLBuild) = 10.50
BEGIN
-- Hardware information from SQL Server 2008 R2  (Query 10) (Hardware Info)

    SET @STRSQL
        = 'SELECT @@SERVERNAME as SQLInstance,cpu_count AS [LogicalCPUCount],
	scheduler_count as SchedulerCount,
	hyperthread_ratio AS [HyperthreadRatio],
cpu_count/hyperthread_ratio AS [PhysicalCPUCount],
physical_memory_in_bytes/1048576 AS [PhysicalMemoryMB],
	bpool_committed/1024 AS [CommittedMemoryMB],
       bpool_commit_target/1024 AS [CommittedTargetMemoryMB],
       max_workers_count AS [MaxWorkersCount],
	   affinity_type_desc AS [AffinityType],
sqlserver_start_time [SQLServerStartTime],
DATEDIFF(hour, sqlserver_start_time, GETDATE()) AS [SQLServerUpTimeHrs],
''UNKNOWN'' AS [VirtualMachineType],
GETDATE() as collect_date
FROM sys.dm_os_sys_info WITH (NOLOCK) OPTION (RECOMPILE);';

    EXEC (@STRSQL);
END;
ELSE
BEGIN
    -- Hardware information from SQL Server 2008 (Query 10) (Hardware Info)

    SET @STRSQL
        = 'SELECT @@SERVERNAME as SQLInstance,cpu_count AS [LogicalCPUCount],
	scheduler_count as SchedulerCount,
	hyperthread_ratio AS [HyperthreadRatio],
cpu_count/hyperthread_ratio AS [PhysicalCPUCount],
physical_memory_in_bytes/1048576 AS [PhysicalMemoryMB],
	bpool_committed/1024 AS [CommittedMemoryMB],
       bpool_commit_target/1024 AS [CommittedTargetMemoryMB],
       max_workers_count AS [MaxWorkersCount],
	   ''UNKNOWN'' AS [AffinityType],
sqlserver_start_time [SQLServerStartTime],
DATEDIFF(hour, sqlserver_start_time, GETDATE()) AS [SQLServerUpTimeHrs],
''UNKNOWN'' AS [VirtualMachineType],
GETDATE() as collect_date
FROM sys.dm_os_sys_info WITH (NOLOCK) OPTION (RECOMPILE);';

    EXEC (@STRSQL);
END;
