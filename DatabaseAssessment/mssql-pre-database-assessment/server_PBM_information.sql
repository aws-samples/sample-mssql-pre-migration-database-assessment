/*
#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

*/

/*
Author:       Marcelo Fernandes (marcesl)
Date:         10/04/2021
Description:  Script to list all PBM policies in the instance server
Permission:   db_datareader on msdb database

Author: 		Marcelo Fernandes (marcesl)
Date: 			03/04/2025
Description: 	adjusted for SQL 2008

*/


DECLARE @SQLBuild DECIMAL(4,2) = 0,
        @STRSQL VARCHAR(MAX);
SELECT @SQLBuild = CAST(LEFT(CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(50)), 4) AS DECIMAL(4,2))
IF (@SQLBuild) >= 10.50
BEGIN
    SET @STRSQL
        = 'SELECT @@SERVERNAME AS SQLInstance,
		a.name AS ''Policy'',
		c.name as ''Condition'',
		c.facet,
		a.date_created,
		a.date_modified,
		CASE WHEN a.execution_mode = 0 THEN ''OnDemand''
			 WHEN a.execution_mode & 1 = 1 THEN ''OnChangePrevent''
			 WHEN a.execution_mode & 2 = 2 THEN ''OnChangeLogOnly''
			 WHEN a.execution_mode & 4 = 4 THEN ''OnSchedule''
		ELSE ''null'' END AS execution_mode,
		getdate() as collect_date
	FROM msdb.dbo.syspolicy_policies_internal (NOLOCK) a
		INNER JOIN msdb.dbo.syspolicy_conditions (NOLOCK) c
		ON a.condition_id = c.condition_id
	WHERE a.is_system = 0
	ORDER BY a.Name;';
    EXEC (@STRSQL);
END
ELSE
BEGIN
	SELECT @@SERVERNAME AS SQLInstance,
		a.name AS 'Policy',
		c.name as 'Condition',
		c.facet,
		a.date_created,
		a.date_modified,
		CASE WHEN a.execution_mode = 0 THEN 'OnDemand'
			 WHEN a.execution_mode & 1 = 1 THEN 'OnChangePrevent'
			 WHEN a.execution_mode & 2 = 2 THEN 'OnChangeLogOnly'
			 WHEN a.execution_mode & 4 = 4 THEN 'OnSchedule'
		ELSE 'null' END AS execution_mode,
		getdate() as collect_date
	FROM msdb.dbo.syspolicy_policies_internal (NOLOCK) a
		INNER JOIN msdb.dbo.syspolicy_conditions (NOLOCK) c
		ON a.condition_id = c.condition_id
	ORDER BY a.Name;
END
