/*
#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

*/

/*
Author: 		Marcos Freccia (mfreccia)
Date: 			29/11/2022
Description: 	Script to collect primary key information
Permission:     public permission on the databases
*/

SELECT @@SERVERNAME AS SQLInstance, DB_NAME() AS DatabaseName, schema_name(tab.schema_id) AS SchemaName,
    tab.[name] AS TableName , getdate() AS collect_date
FROM sys.tables (NOLOCK) tab
    LEFT OUTER JOIN sys.indexes (NOLOCK) pk
    ON tab.object_id = pk.object_id
        AND pk.is_primary_key = 1
WHERE pk.object_id IS NULL
ORDER BY schema_name(tab.schema_id), tab.[name]
