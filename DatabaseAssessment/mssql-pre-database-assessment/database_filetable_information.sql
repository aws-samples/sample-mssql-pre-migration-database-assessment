/*
#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0
*/

/*
Author:         Ashish Srivastava (sriashk)
Description:    Script to detect File Tables usage (unsupported on RDS)
Permission:     VIEW ANY DEFINITION
*/

DECLARE @SQLBuild INT = 0,
        @STRSQL NVARCHAR(MAX);
SELECT @SQLBuild = SUBSTRING(CAST(SERVERPROPERTY('productversion') AS VARCHAR), 0, CHARINDEX('.', CAST(SERVERPROPERTY('productversion') AS VARCHAR)));

IF (@SQLBuild) >= 11 -- SQL Server 2012+
BEGIN
    SET @STRSQL = N'
    SELECT @@SERVERNAME AS SQLInstance,
           DB_NAME() AS DatabaseName,
           s.name AS SchemaName,
           t.name AS TableName,
           t.create_date,
           GETDATE() AS collect_date
    FROM sys.filetables AS t
    JOIN sys.schemas AS s ON t.schema_id = s.schema_id'
    EXEC sp_executesql @STRSQL
END