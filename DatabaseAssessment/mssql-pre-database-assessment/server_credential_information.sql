/*
#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

*/

/*
Author:      Marcelo Fernandes (marcesl)
Date:        10/07/2021
Description: Script list the existing Credentials
Permission:  VIEW ANY DEFINITION
*/
SELECT
	@@SERVERNAME AS SQLInstance,
	c.credential_id,
	c.name AS Credential_Name,
	c.credential_identity,
	p.name AS Principal_Name,
	p.type_desc,
	ISNULL(cast(p.is_disabled as varchar),'False') as is_disabled,
	p.default_database_name,
	px.name AS Proxy_Name,
	px.enabled,
	px.description,
	getdate() as collect_date
FROM master.sys.credentials (NOLOCK) c
	LEFT JOIN master.sys.server_principals (NOLOCK) p
	ON  c.credential_id = p.credential_id
	LEFT JOIN msdb..sysproxies (NOLOCK) px
	ON  c.credential_id = px.credential_id
