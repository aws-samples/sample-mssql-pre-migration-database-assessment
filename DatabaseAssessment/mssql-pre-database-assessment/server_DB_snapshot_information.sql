/*
#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

*/

/*
Author:         Marcelo Fernandes (marcesl)
Date:           29/11/2022
Description:    Script to check if instance has Snapshot database
Permission:     VIEW SERVER STATE
*/

SELECT @@SERVERNAME AS SQLInstance,
       name AS SnapshotDatabaseName,
       DB_NAME(source_database_id) AS SourceDatabaseName,
       create_date,
       GETDATE() AS collect_date
FROM sys.databases (NOLOCK)
WHERE source_database_id IS NOT NULL;
