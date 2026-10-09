/*
#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

*/

/*
Author:         Marcelo Fernandes (marcesl)
Date:           10/04/2021
Description:    Script to check if database is using InMemory feature, will list all tables using inMemory
Permissions:	All rows are returned if you have VIEW DATABASE STATE permission on the current database. Otherwise, an empty rowset is returned.
				If you do not have VIEW DATABASE permission, all columns will be returned for rows in tables that you have SELECT permission on.
*/
DECLARE @SQLBuild INT=0, @STRSQL VARCHAR(600)
SELECT @SQLBuild = SUBSTRING(CAST(SERVERPROPERTY('productversion') AS VARCHAR),0,charindex('.',CAST(SERVERPROPERTY('productversion') AS VARCHAR)))

if(@SQLBuild)>11
BEGIN
	 SET @STRSQL='SELECT @@SERVERNAME AS SQLInstance,DB_NAME() AS DatabaseName,SCHEMA_NAME(schema_id) as SchemaName,OBJECT_NAME(MS.object_id) TableName,
					TB.durability_desc, TB.create_date, TB.modify_date,getdate() as collect_date
					FROM sys.dm_db_xtp_table_memory_stats (NOLOCK) AS MS
					INNER JOIN sys.tables (NOLOCK) AS TB ON MS.object_id = TB.object_id
					 WHERE MS.object_id > 0;'
	 EXEC (@STRSQL)
END
