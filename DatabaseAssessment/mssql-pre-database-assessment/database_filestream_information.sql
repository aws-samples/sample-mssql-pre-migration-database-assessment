/*
#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

*/

/*
Author:         Marcos Freccia (mfreccia)
Date:           27/07/2021
Description:    Script to list databases with filestream enabled
Permission:     VIEW SERVER STATE
*/

DECLARE @SQLBuild INT = 0,
        @STRSQL VARCHAR(MAX);
SELECT @SQLBuild
    = SUBSTRING(
                   CAST(SERVERPROPERTY('productversion') AS VARCHAR),
                   0,
                   CHARINDEX('.', CAST(SERVERPROPERTY('productversion') AS VARCHAR))
               );
IF (@SQLBuild) > 10
BEGIN
    SET @STRSQL = 'SELECT @@SERVERNAME AS SQLInstance,DB_NAME(database_id) AS DatabaseName,
       non_transacted_access,
       non_transacted_access_desc,
       directory_name,
	   GETDATE() AS collect_date
	   FROM sys.database_filestream_options (NOLOCK) WHERE non_transacted_access <> 0'
	EXEC (@STRSQL)
END
