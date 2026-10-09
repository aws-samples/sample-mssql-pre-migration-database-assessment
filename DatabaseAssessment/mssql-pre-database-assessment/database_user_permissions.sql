/*
#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

*/

/*
Author: 	 Marcos Freccia (mfreccia)
Date: 		 29/11/2022
Description: Script to retrieve list of users per database and their permissions
Permission:  db_owner on the respective database
*/

SELECT DISTINCT @@SERVERNAME as SQLInstance, DB_NAME() as DatabaseName,
       dbp.name AS DatabaseUser,
       dbp.type_desc AS UserType,
       dbp.create_date AS CreateDate,
       SUBSTRING(
       (
           SELECT DISTINCT ';' + roles2.name AS [text()]
           FROM sys.database_principals AS dbp2
               LEFT JOIN sys.database_role_members (NOLOCK) AS dbrm2
                   LEFT JOIN sys.database_principals (NOLOCK) AS roles2
                       ON dbrm2.role_principal_id = roles2.principal_id
                   ON dbp.principal_id = dbrm2.member_principal_id
           WHERE dbp2.type IN ( 'S', 'U', 'G' )
                 AND dbp2.principal_id > 4
           FOR XML PATH('')
       ),
       2,
       1000
                ) Roles,	getdate() as collect_date
FROM sys.database_principals (NOLOCK) AS dbp
WHERE dbp.type IN ( 'S', 'U', 'G' )
      AND dbp.principal_id > 4;
