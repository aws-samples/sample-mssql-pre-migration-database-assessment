/*
#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

*/

/*
Author: 	 Marcelo Fernandes (marcesl)
Date: 		 01/10/2021
Description: Script to List existent Server Triggers
Permission:  VIEW SERVER STATE

*/
SELECT @@SERVERNAME AS SQLInstance,
    ST.name,
    ST.parent_class_desc,
    ST.type_desc,
    ST.create_date,
    ST.modify_date,
    ST.is_ms_shipped,
    ST.is_disabled,
    STE.type_desc AS 'event_type_desc',
    STE.event_group_type_desc,
	getdate() as collect_date
FROM sys.server_triggers (NOLOCK) AS ST
INNER JOIN sys.server_trigger_events (NOLOCK) AS STE
ON ST.object_id = STE.object_id
