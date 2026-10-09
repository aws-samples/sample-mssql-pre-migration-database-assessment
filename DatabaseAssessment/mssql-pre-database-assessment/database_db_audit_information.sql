/*
#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

*/

/*
Author:         Marcelo Fernandes (marcesl)
Date:           10/07/2021
Description:    Script to list the existing Database Audit
Permissions: 	ALTER ANY SERVER AUDIT, Public role in the user database
				Principals with the ALTER ANY DATABASE AUDIT or VIEW DEFINITION permissions,
				the dbo role, and members of the db_owners fixed database role have access to this catalog view.
				In addition, the principal must not be denied VIEW DEFINITION permission.
*/

SELECT	@@SERVERNAME AS SQLInstance,
		a.audit_id,
		a.name as audit_name,
		s.name as database_specification_name,
		d.audit_action_name,
		s.is_state_enabled,
		d.is_group,
		s.create_date,
		d.audited_result,
		db_name() AS [DatabaseName],
		getdate() as collect_date
FROM sys.server_audits (NOLOCK) AS a
	JOIN sys.database_audit_specifications (NOLOCK) AS s
	ON a.audit_guid = s.audit_guid
	JOIN sys.database_audit_specification_details (NOLOCK) AS d
	ON s.database_specification_id = d.database_specification_id
WHERE s.is_state_enabled = 1
