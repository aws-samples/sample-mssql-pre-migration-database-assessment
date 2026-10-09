/*
#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

*/

/*
Author: 		Marcos Freccia (mfreccia)
Date: 			29/11/2022
Description: 	Script to collect I/O utilization
Permission:     VIEW SERVER STATE

Author: 		Marcelo Fernandes (marcesl)
Date: 			03/04/2025
Description: 	Fixed divided by zero when calculating the WriteIOPercent
*/


WITH Aggregate_IO_Statistics
AS (SELECT DB_NAME(database_id) AS [DatabaseName],
    CAST(SUM(num_of_bytes_read + num_of_bytes_written) / 1048576 AS DECIMAL(12, 2)) AS [ioTotalMB],
    CAST(SUM(num_of_bytes_read ) / 1048576 AS DECIMAL(12, 2)) AS [ioReadMB],
    CAST(SUM(num_of_bytes_written) / 1048576 AS DECIMAL(12, 2)) AS [ioWriteMB]
    FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS [DM_IO_STATS]
    GROUP BY database_id)
SELECT @@SERVERNAME as SQLInstance,
		ROW_NUMBER() OVER (ORDER BY ioTotalMB DESC) AS [IORank],
        [DatabaseName], ioTotalMB AS [TotalIOMB],
        CAST(ioTotalMB / SUM(ioTotalMB) OVER () * 100.0 AS DECIMAL(5, 2)) AS [TotalIOPercent],
        ioReadMB AS [ReadIOMB],
		CAST(ioReadMB / SUM(ioReadMB) OVER () * 100.0 AS DECIMAL(5, 2)) AS [ReadIOPercent],
        ioWriteMB AS [WriteIOMB],
		CAST(ioWriteMB / NULLIF(SUM(ioWriteMB) OVER (), 0) * 100.0 AS DECIMAL(5, 2)) AS [WriteIOPercent]
		,getdate() as collect_date
FROM Aggregate_IO_Statistics
ORDER BY [IORank] OPTION (RECOMPILE);
------
