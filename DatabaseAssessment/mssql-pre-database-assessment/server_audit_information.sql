/*
#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

*/

/*
Author:      Marcelo Fernandes (marcesl)
Date:        10/07/2021
Description: Script list the existing Server Audit
Permission:  VIEW ANY DEFINITION
*/

SELECT @@SERVERNAME as SQLInstance,
	audit_id,
	a.name as audit_name,
	s.name as server_specification_name,
	d.audit_action_name,
	s.is_state_enabled,
	d.is_group,
	d.audit_action_id,
	s.create_date,
	s.modify_date,
	getdate() as collect_date
FROM sys.server_audits (NOLOCK) AS a
	LEFT JOIN sys.server_audit_specifications (NOLOCK) AS s
	ON a.audit_guid = s.audit_guid
	LEFT JOIN sys.server_audit_specification_details (NOLOCK) AS d
	ON s.server_specification_id = d.server_specification_id
WHERE s.is_state_enabled = 1
