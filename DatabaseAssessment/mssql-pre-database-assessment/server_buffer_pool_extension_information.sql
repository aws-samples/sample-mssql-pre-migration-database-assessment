/*
#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

*/

/*
Author:      Marcos Freccia (mfreccia)
Date:        27/07/2021
Description: Script to check if Buffer Pool Extension is enabled
Permission:  VIEW SERVER STATE
*/

DECLARE @SQLBuild INT = 0,
        @STRSQL VARCHAR(600);
SELECT @SQLBuild
    = SUBSTRING(
                   CAST(SERVERPROPERTY('productversion') AS VARCHAR),
                   0,
                   CHARINDEX('.', CAST(SERVERPROPERTY('productversion') AS VARCHAR))
               );

IF (@SQLBuild) > 11
BEGIN
    SELECT @@SERVERNAME AS SQLInstance,
        path,
        file_id,
        state,
        state_description,
        current_size_in_kb,
        GETDATE() AS collect_date
    FROM sys.dm_os_buffer_pool_extension_configuration (NOLOCK)
    WHERE state <> 0;
END;
