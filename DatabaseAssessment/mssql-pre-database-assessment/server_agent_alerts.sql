/*
#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

*/

/*
Author:      Marcelo Fernandes (marcesl)
Date: 	      01/10/2021
Description: Script to retrieve SQL Server Agent Alerts
Permission:  VIEW SERVER STATE

*/

SELECT @@SERVERNAME as SQLInstance, name as 'AlertName',
	event_source as 'EventSource',
	message_id as 'MessageID',
	severity, [enabled] as 'Enabled',
	has_notification,
	delay_between_responses,
	occurrence_count,
	last_occurrence_date,
	last_occurrence_time,
	getdate() as collect_date
FROM msdb.dbo.sysalerts WITH (NOLOCK)
ORDER BY name
OPTION
(RECOMPILE);
