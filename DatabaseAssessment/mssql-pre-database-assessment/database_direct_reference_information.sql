/*
#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

*/

/*
Author: 		Marcos Freccia (mfreccia)
Date: 			08/11/2021
Description: 	Script to identify three and four part names in SQL Server code
Permission:     VIEW DATABASE DEFINITION, db_owner
*/
SELECT @@SERVERNAME AS SQLInstance,
       DB_NAME(DB_ID()) AS referencing_database_name,
       OBJECT_SCHEMA_NAME(objects.object_id) AS referencing_schema_name,
       objects.name AS referencing_object_name,
       objects.type_desc referencing_object_type,
       CASE
           WHEN referenced_database_name = DB_NAME()
                AND referenced_server_name IS NULL THEN
               'Internal'
           ELSE
               'External'
       END AS referenced_database_location,
       COALESCE(sql_expression_dependencies.referenced_server_name, '<localserver>') AS referenced_server_name,
       sql_expression_dependencies.referenced_database_name,
       sql_expression_dependencies.referenced_schema_name,
       sql_expression_dependencies.referenced_entity_name AS referenced_object_name,
       GETDATE() AS collect_date
FROM sys.sql_expression_dependencies (NOLOCK)
    JOIN sys.objects (NOLOCK)
        ON objects.object_id = sql_expression_dependencies.referencing_id
WHERE referenced_database_name IS NOT NULL
ORDER BY referencing_schema_name,
         referencing_object_name;
