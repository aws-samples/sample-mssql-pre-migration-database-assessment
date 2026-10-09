/*
#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

*/

/*
Author:         Marcos Freccia (mfreccia)
Date:           25/11/2022
Description:    Script to retrieve CPU Utilization per database
Permission:     On SQL Server and SQL Managed Instance, requires VIEW SERVER STATE permission.
*/

WITH DB_CPU_Stats
AS
(SELECT pa.DatabaseID, DB_Name(pa.DatabaseID) AS [DatabaseName], SUM(qs.total_worker_time/1000) AS [CPU_Time_Ms]
 FROM sys.dm_exec_query_stats AS qs WITH (NOLOCK)
 CROSS APPLY (SELECT CONVERT(int, value) AS [DatabaseID]
              FROM sys.dm_exec_plan_attributes(qs.plan_handle)
              WHERE attribute = N'dbid') AS pa
 GROUP BY DatabaseID)
SELECT @@SERVERNAME AS SQLInstance,
		ROW_NUMBER() OVER(ORDER BY [CPU_Time_Ms] DESC) AS [CPURank],
       [DatabaseName], [CPU_Time_Ms] AS [CPUTimeMiliSecond],
       CAST([CPU_Time_Ms] * 1.0 / SUM([CPU_Time_Ms]) OVER() * 100.0 AS DECIMAL(5, 2)) AS [CPUPercent],
	   getdate() as collect_date
FROM DB_CPU_Stats
WHERE DatabaseID <> 32767 -- ResourceDB
ORDER BY [CPURank] OPTION (RECOMPILE);
