/*
#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

*/

/*
Author: 		Marcos Freccia (mfreccia)
Date: 			29/11/2022
Description: 	Script to retrieve information about disk drives only where database files are hosted
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
    -- SQL Server 2012 and later
    SELECT DISTINCT 
        @@SERVERNAME as SQLInstance,
        ISNULL(vs.volume_mount_point, 'N/A') as DriveLetter, 
        ISNULL(vs.file_system_type, 'N/A') as FileSystem, 
        ISNULL(vs.logical_volume_name, 'N/A') as LogicalVolumeName,
        CONVERT(DECIMAL(18,2), vs.total_bytes/1073741824.0) AS [TotalSizeGB],
        CONVERT(DECIMAL(18,2), vs.available_bytes/1073741824.0) AS [AvailableSizeGB],
        CONVERT(DECIMAL(18,2), vs.available_bytes * 1. / vs.total_bytes * 100.) AS SpaceFreePercent,
        ISNULL(vs.is_compressed, 0) as CompressedVolume,
        GETDATE() as collect_date
    FROM sys.master_files AS f WITH (NOLOCK)
    CROSS APPLY sys.dm_os_volume_stats(f.database_id, f.[file_id]) AS vs
	ORDER BY DriveLetter OPTION (RECOMPILE);
END
ELSE IF (SELECT value_in_use from sys.configurations WHERE name = 'xp_cmdshell')>0
BEGIN
	-- Create temporary table
	CREATE TABLE #DriveInfo (
		LineItem VARCHAR(1000)
	);

	-- Get volume information with values already converted to GB in PowerShell
	INSERT INTO #DriveInfo
	EXEC xp_cmdshell 'powershell "Get-WmiObject -Class Win32_Volume | Select-Object Caption, @{Name=''CapacityGB'';Expression={[math]::Round($_.Capacity/1GB,2)}}, @{Name=''FreeSpaceGB'';Expression={[math]::Round($_.FreeSpace/1GB,2)}} | ConvertTo-Csv"';

	-- Clean and display results
	;with CTE_DATA AS(
	SELECT 
		REPLACE(LTRIM(RTRIM(SUBSTRING(LineItem, 0, CHARINDEX(',', LineItem)))),'"','') as [DriveLetter],
		CAST(REPLACE(LTRIM(RTRIM(SUBSTRING(LineItem, CHARINDEX(',', LineItem) + 1,CHARINDEX(',', LineItem, CHARINDEX(',', LineItem) + 1) - CHARINDEX(',', LineItem) - 1))),'"','') as decimal(18,2))as [CapacityGB],
		CAST(REPLACE(LTRIM(RTRIM(REVERSE(SUBSTRING(reverse(LineItem), 0, CHARINDEX(',', reverse(LineItem)))))),'"','') as decimal(18,2)) as [FreeSpaceGB]    
	FROM #DriveInfo
	WHERE len(LineItem) > 1
		AND LineItem != ''
		AND LineItem NOT LIKE '%Caption%'
		AND LineItem NOT LIKE '%PSComputerName%'
		AND LineItem NOT LIKE '%#TYPE%'
		AND LineItem LIKE '"%'
	)
	SELECT @@SERVERNAME as SQLInstance,DriveLetter,
		'N/A' as FileSystem, 
        'N/A' as LogicalVolumeName,
        [CapacityGB] AS [TotalSizeGB],
        [FreeSpaceGB] AS [AvailableSizeGB],
        CAST(ROUND([FreeSpaceGB] * 100.0 / [CapacityGB], 2) AS DECIMAL(10,2)) AS SpaceFreePercent,
        null as CompressedVolume,
        GETDATE() as collect_date		
	FROM CTE_DATA
	ORDER BY [DriveLetter]	
	-- Cleanup
	DROP TABLE #DriveInfo;
END
ELSE
BEGIN
    -- SQL Server 2008
	IF OBJECT_ID('tempdb..#xp_fixeddrives') IS NOT NULL DROP TABLE #xp_fixeddrives;
	CREATE TABLE #xp_fixeddrives
	(
		Drive varchar(250),
		MBFree int
	)
	INSERT INTO #xp_fixeddrives
	(Drive,MBFree)
	EXEC master..xp_fixeddrives

    SELECT DISTINCT 
        @@SERVERNAME as SQLInstance,
        LEFT(f.physical_name, 1) as DriveLetter, 
        'N/A' as FileSystem, 
        'N/A' as LogicalVolumeName,
        NULL AS [TotalSizeGB],
        (CONVERT(Decimal(15,2), d.MBFree)/1024) AS [AvailableSizeGB],
        NULL AS SpaceFreePercent,
        0 as CompressedVolume,
        GETDATE() as collect_date
    FROM sys.master_files AS f WITH (NOLOCK) LEFT JOIN #xp_fixeddrives d
		ON LEFT(f.physical_name, 1) = d.Drive ;
END
