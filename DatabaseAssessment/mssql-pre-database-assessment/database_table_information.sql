/*
#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

*/

/*
Author:         Marcos Freccia (mfreccia)
Date:           25/11/2022
Description:    Script to retrieve list of tables for a database
Permissions:	The visibility of the metadata in catalog views is limited to securables that a
                user either owns or on which the user has been granted some permission.
*/

SELECT @@SERVERNAME AS SQLInstance, DB_NAME() AS DatabaseName, sch.name AS SchemaName,
    ob.name as TableName, getdate() AS collect_date
FROM sys.objects (NOLOCK) AS ob
    JOIN sys.schemas (NOLOCK) AS sch
    ON ob.schema_id = sch.schema_id
WHERE type_desc = 'USER_TABLE'
    AND is_ms_shipped = 0
