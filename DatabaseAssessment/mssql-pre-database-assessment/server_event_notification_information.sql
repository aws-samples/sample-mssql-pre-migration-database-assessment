/*
#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

*/

/*
Author: 	 Marcelo Fernandes (marcesl)
Date: 		 29/11/2022
Description: Script to list event notification on server level
Permission:  The visibility of the metadata in catalog views is limited to securables that a user either owns or on which the user has been granted some permission
*/

SELECT @@SERVERNAME as SQLInstance,
	name,object_id,parent_class_desc,create_date,service_name,
	getdate() as collect_date
FROM sys.server_event_notifications (NOLOCK);
