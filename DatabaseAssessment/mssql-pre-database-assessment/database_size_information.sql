/*
#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

*/

/*
Author:         Marcos Freccia (mfreccia)
Date:           25/11/2022
Description:    Script to retrieve file sizes for individual database
Permissions:	Requires membership in the public role
*/

-- Individual File Sizes and space available for current database  (Query 49) (File Sizes and Space)
SELECT @@SERVERNAME AS SQLInstance,
    DB_NAME() as 'DatabaseName', f.name AS [FileName] , f.physical_name AS [PhysicalName],f.type_desc as FileType,
    ISNULL(fg.type_desc,'N/A') as FilegroupType,
    CAST((f.size/128.0) AS DECIMAL(15,2)) AS [TotalSizeinMB],
    ISNULL(CAST(f.size/128.0 - CAST(FILEPROPERTY(f.name, 'SpaceUsed') AS int)/128.0 AS DECIMAL(15,2)),0)
AS [AvailableSpaceInMB],
    ISNULL(CAST((f.size/128.0) AS DECIMAL(15,2)) -
CAST(f.size/128.0 - CAST(FILEPROPERTY(f.name, 'SpaceUsed') AS int)/128.0 AS DECIMAL(15,2)),0) AS [UsedSpaceinMB]
, getdate() as collect_date
FROM sys.database_files AS f WITH (NOLOCK)
    LEFT OUTER JOIN sys.filegroups AS fg WITH (NOLOCK)
    ON f.data_space_id = fg.data_space_id
ORDER BY f.[file_id]
OPTION
(RECOMPILE);
