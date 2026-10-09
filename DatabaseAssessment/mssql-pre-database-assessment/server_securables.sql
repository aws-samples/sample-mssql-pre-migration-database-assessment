/*
#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

*/

/*
Author: 	 Marcos Freccia (mfreccia)
Date: 		 30/11/2022
Description: Script to retrieve list of logins per instance and their server level securables
Permission:  ALTER ANY LOGIN
*/

SELECT DISTINCT @@SERVERNAME as SQLInstance, pr.name as LoginName,
	SUBSTRING(
	(
		SELECT DISTINCT ';{"state_desc": "' + pe2.state_desc + '"; "permission_name" : "' + pe2.permission_name + '"}' as [text()]
		FROM sys.server_principals (NOLOCK) AS pr2
		JOIN sys.server_permissions (NOLOCK) AS pe2
			ON pe2.grantee_principal_id = pr2.principal_id
			AND pe.grantee_principal_id = pr2.principal_id

			FOR XML PATH('')),2,3000) as securables,
	getdate() as collect_date
FROM sys.server_principals (NOLOCK) AS pr
JOIN sys.server_permissions (NOLOCK) AS pe
    ON pe.grantee_principal_id = pr.principal_id
	WHERE name NOT LIKE '##%##'
	AND name NOT LIKE ('NT SERVICE%')
	AND name NOT LIKE ('NT AUTHORITY%')
	AND NAME NOT IN ('public','sa','rdsa')
