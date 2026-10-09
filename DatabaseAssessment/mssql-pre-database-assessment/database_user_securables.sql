/*
#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

*/

/*
Author: 	 Marcos Freccia (mfreccia)
Date: 		 30/11/2022
Description: Script to retrieve list of users per database and their securables
Permission:  ALTER ANY USER
*/

SELECT DISTINCT @@SERVERNAME as SQLInstance, pr.name as UserName, pr.type_desc,
	SUBSTRING(
	(
		SELECT DISTINCT ';{"object_name": "' +s2.name + '.' + o2.name COLLATE SQL_Latin1_General_CP1_CI_AS  +'"; "state_desc": "' + pe2.state_desc + '"; "permission_name" : "' + pe2.permission_name + '"}' as [text()]
	FROM sys.database_principals (NOLOCK) AS pr2
		JOIN sys.database_permissions (NOLOCK) AS pe2
		ON pe2.grantee_principal_id = pr2.principal_id
			AND pe.grantee_principal_id = pr2.principal_id
		JOIN sys.objects (NOLOCK) AS o2
		ON pe2.major_id = o2.object_id
			AND pe.major_id = o2.object_id
		JOIN sys.schemas (NOLOCK) AS s2
		ON o2.schema_id = s2.schema_id
			AND o2.schema_id = s.schema_id

	FOR XML PATH('')),2,2500) as securables,
	getdate() as collect_date
FROM sys.database_principals (NOLOCK) AS pr
	JOIN sys.database_permissions (NOLOCK) AS pe
	ON pe.grantee_principal_id = pr.principal_id
	JOIN sys.objects (NOLOCK) AS o
	ON pe.major_id = o.object_id
	JOIN sys.schemas (NOLOCK) AS s
	ON o.schema_id = s.schema_id;
