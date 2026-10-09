/*
#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

*/

/*
Author: 		Marcos Freccia (mfreccia)
Date: 			29/11/2022
Description: 	Script to retrieve latency for the disks where database files are hosted
Permission:     VIEW SERVER STATE

Author: 		Marcelo Fernandes (marcesl)
Date: 			03/04/2025
Description: 	adjusted for SQL 2008/2008R2

-- for SQL 2008R2 and ealier xp_cmdshell required to collect details for Mount Point
-- Enable xp_cmdshell
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'xp_cmdshell', 1;
RECONFIGURE;

*/


IF  CAST(LEFT(CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(50)), 4) AS DECIMAL(4,2)) > 10.50
BEGIN
	SELECT @@SERVERNAME AS SQLInstance,
		tab.[Drive], tab.volume_mount_point AS [VolumeMountPoint],
		CASE
			WHEN num_of_reads = 0 THEN 0
			ELSE (io_stall_read_ms/num_of_reads)
		END AS [ReadLatency],
		CASE
			WHEN num_of_writes = 0 THEN 0
			ELSE (io_stall_write_ms/num_of_writes)
		END AS [WriteLatency],
		CASE
			WHEN (num_of_reads = 0 AND num_of_writes = 0) THEN 0
			ELSE (io_stall/(num_of_reads + num_of_writes))
		END AS [OverallLatency],
		CASE
			WHEN num_of_reads = 0 THEN 0
			ELSE (num_of_bytes_read/num_of_reads)
		END AS [AvgBytesRead],
		CASE
			WHEN num_of_writes = 0 THEN 0
			ELSE (num_of_bytes_written/num_of_writes)
		END AS [AvgBytesWrite],
		CASE
			WHEN (num_of_reads = 0 AND num_of_writes = 0) THEN 0
			ELSE ((num_of_bytes_read + num_of_bytes_written)/(num_of_reads + num_of_writes))
		END AS [AvgBytesTransfer],
		getdate() as collect_date
	FROM (SELECT LEFT(UPPER(mf.physical_name), 2) AS Drive, SUM(num_of_reads) AS num_of_reads,
				 SUM(io_stall_read_ms) AS io_stall_read_ms, SUM(num_of_writes) AS num_of_writes,
				 SUM(io_stall_write_ms) AS io_stall_write_ms, SUM(num_of_bytes_read) AS num_of_bytes_read,
				 SUM(num_of_bytes_written) AS num_of_bytes_written, SUM(io_stall) AS io_stall, vs.volume_mount_point
		  FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS vfs
		  INNER JOIN sys.master_files AS mf WITH (NOLOCK)
		  ON vfs.database_id = mf.database_id AND vfs.file_id = mf.file_id
		  CROSS APPLY sys.dm_os_volume_stats(mf.database_id, mf.[file_id]) AS vs
		  GROUP BY LEFT(UPPER(mf.physical_name), 2), vs.volume_mount_point) AS tab
	ORDER BY [OverallLatency] OPTION (RECOMPILE);
END
ELSE IF (SELECT value_in_use from sys.configurations WHERE name = 'xp_cmdshell')>0
BEGIN
		-- Create a temporary table to store drive information
	IF OBJECT_ID('tempdb..#TempDriveInfo') IS NOT NULL DROP TABLE #TempDriveInfo;
	CREATE TABLE #TempDriveInfo (LineItem VARCHAR(1000)
	);	
	INSERT INTO #TempDriveInfo	
	EXEC xp_cmdshell 'powershell "Get-WmiObject -Class Win32_Volume | Select-Object Caption, @{Name=''FreeSpaceMB'';Expression={[math]::Round($_.FreeSpace/1MB,2)}} | ConvertTo-Csv"';

	IF OBJECT_ID('tempdb..#DriveInfo') IS NOT NULL DROP TABLE #DriveInfo;
	CREATE TABLE #DriveInfo (Drive VARCHAR(50), MBFree DECIMAL(18,2));
	
	INSERT INTO #DriveInfo
	select 
		REPLACE(LTRIM(RTRIM(SUBSTRING(LineItem, 0, CHARINDEX(',', LineItem)))),'"','') as [Drive],
		CAST(REPLACE(LTRIM(RTRIM(REVERSE(SUBSTRING(reverse(LineItem), 0, CHARINDEX(',', reverse(LineItem)))))),'"','') as decimal(18,2)) as [FreeSpaceMB]
	from #TempDriveInfo
	WHERE len(LineItem) > 1
		AND LineItem != ''
		AND LineItem NOT LIKE '%Caption%'
		AND LineItem NOT LIKE '%PSComputerName%'
		AND LineItem NOT LIKE '%#TYPE%'
		AND LineItem LIKE '"%'

	-- Main query
	SELECT @@SERVERNAME AS SQLInstance,
		tab.[Drive], tab.volume_mount_point AS [VolumeMountPoint],
		CASE
			WHEN num_of_reads = 0 THEN 0
			ELSE (io_stall_read_ms/num_of_reads)
		END AS [ReadLatency],
		CASE
			WHEN num_of_writes = 0 THEN 0
			ELSE (io_stall_write_ms/num_of_writes)
		END AS [WriteLatency],
		CASE
			WHEN (num_of_reads = 0 AND num_of_writes = 0) THEN 0
			ELSE (io_stall/(num_of_reads + num_of_writes))
		END AS [OverallLatency],
		CASE
			WHEN num_of_reads = 0 THEN 0
			ELSE (num_of_bytes_read/num_of_reads)
		END AS [AvgBytesRead],
		CASE
			WHEN num_of_writes = 0 THEN 0
			ELSE (num_of_bytes_written/num_of_writes)
		END AS [AvgBytesWrite],
		CASE
			WHEN (num_of_reads = 0 AND num_of_writes = 0) THEN 0
			ELSE ((num_of_bytes_read + num_of_bytes_written)/(num_of_reads + num_of_writes))
		END AS [AvgBytesTransfer],
		getdate() as collect_date
	FROM (SELECT LEFT(UPPER(mf.physical_name), 2) AS Drive, SUM(num_of_reads) AS num_of_reads,
				 SUM(io_stall_read_ms) AS io_stall_read_ms, SUM(num_of_writes) AS num_of_writes,
				 SUM(io_stall_write_ms) AS io_stall_write_ms, SUM(num_of_bytes_read) AS num_of_bytes_read,
				 SUM(num_of_bytes_written) AS num_of_bytes_written, SUM(io_stall) AS io_stall, vs.drive as volume_mount_point
		  FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS vfs
		  INNER JOIN sys.master_files AS mf WITH (NOLOCK)
		  ON vfs.database_id = mf.database_id AND vfs.file_id = mf.file_id
		  CROSS APPLY (SELECT Drive FROM #DriveInfo d WHERE mf.physical_name like d.drive+'%' ) vs
		  GROUP BY LEFT(UPPER(mf.physical_name), 2), vs.Drive) AS tab
	ORDER BY [OverallLatency] OPTION (RECOMPILE);
	
END
ELSE
BEGIN

	-- Create a temporary table to store drive information
	IF OBJECT_ID('tempdb..#DriveInfo2') IS NOT NULL DROP TABLE #DriveInfo2;
	CREATE TABLE #DriveInfo2 (Drive CHAR(1), MBFree INT);

	-- Populate the temporary table with xp_fixeddrives data
	INSERT INTO #DriveInfo2
	EXEC master..xp_fixeddrives;

	-- Main query
	SELECT 
		@@SERVERNAME AS SQLInstance,
		tab.[Drive], 
		COALESCE(di.Drive + ':\', 'Unknown') AS [VolumeMountPoint],
		CASE
			WHEN num_of_reads = 0 THEN 0
			ELSE (io_stall_read_ms/num_of_reads)
		END AS [ReadLatency],
		CASE
			WHEN num_of_writes = 0 THEN 0
			ELSE (io_stall_write_ms/num_of_writes)
		END AS [WriteLatency],
		CASE
			WHEN (num_of_reads = 0 AND num_of_writes = 0) THEN 0
			ELSE (io_stall/(num_of_reads + num_of_writes))
		END AS [OverallLatency],
		CASE
			WHEN num_of_reads = 0 THEN 0
			ELSE (num_of_bytes_read/num_of_reads)
		END AS [AvgBytesRead],
		CASE
			WHEN num_of_writes = 0 THEN 0
			ELSE (num_of_bytes_written/num_of_writes)
		END AS [AvgBytesWrite],
		CASE
			WHEN (num_of_reads = 0 AND num_of_writes = 0) THEN 0
			ELSE ((num_of_bytes_read + num_of_bytes_written)/(num_of_reads + num_of_writes))
		END AS [AvgBytesTransfer],
		GETDATE() as collect_date
	FROM 
		(SELECT 
			LEFT(UPPER(mf.physical_name), 1) AS Drive, 
			SUM(num_of_reads) AS num_of_reads,
			SUM(io_stall_read_ms) AS io_stall_read_ms, 
			SUM(num_of_writes) AS num_of_writes,
			SUM(io_stall_write_ms) AS io_stall_write_ms, 
			SUM(num_of_bytes_read) AS num_of_bytes_read,
			SUM(num_of_bytes_written) AS num_of_bytes_written, 
			SUM(io_stall) AS io_stall
		FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS vfs
		INNER JOIN sys.master_files AS mf WITH (NOLOCK)
		ON vfs.database_id = mf.database_id AND vfs.file_id = mf.file_id
		GROUP BY LEFT(UPPER(mf.physical_name), 1)) AS tab
	LEFT JOIN #DriveInfo2 di ON tab.Drive = di.Drive
	ORDER BY [OverallLatency] OPTION (RECOMPILE);

END
