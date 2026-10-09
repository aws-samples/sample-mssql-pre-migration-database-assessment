/*
#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

*/

/*
Author: 		Marcos Freccia (mfreccia)
Date: 			29/11/2022
Description: 	Script to collect logins created in the instance and their server permissions
Permission:     VIEW ANY DEFINITION OR securityadmin server role
*/

SELECT DISTINCT @@SERVERNAME as SQLInstance,SL.name as 'LoginName',
       SUBSTRING(
       (
           SELECT DISTINCT ';' + roles2.name AS [text()]
           FROM sys.server_principals (NOLOCK) AS dbp2
               LEFT JOIN sys.server_role_members (NOLOCK) AS dbrm2
                   LEFT JOIN sys.server_principals (NOLOCK) AS roles2
                       ON dbrm2.role_principal_id = roles2.principal_id
                   ON srm.member_principal_id = dbrm2.member_principal_id
           WHERE dbp2.type IN ( 'S', 'U', 'G' )
                 AND dbp2.principal_id > 4
           FOR XML PATH('')
       ),
       2,
       1000
                ) Roles,getdate() as collect_date
FROM master.sys.server_role_members (NOLOCK) srm
INNER JOIN master.sys.server_principals (NOLOCK) sr ON sr.principal_id = srm.role_principal_id
    JOIN master.sys.server_principals (NOLOCK) sl ON sl.principal_id = srm.member_principal_id
WHERE SL.type IN ('S','G','U')
        AND SL.name NOT LIKE '##%##'
        AND SL.name NOT LIKE 'NT AUTHORITY%'
        AND SL.name NOT LIKE 'NT SERVICE%'
        AND SL.name NOT IN('sa','distributor_admin');
