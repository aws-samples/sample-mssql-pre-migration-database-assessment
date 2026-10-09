/*
#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

*/

/*
Author:      Marcelo Fernandes (marcesl)
Date:        10/04/2021
Description: Script to check if database has Logshipping configured
Permission:  db_datareader on msdb database
*/

SELECT @@SERVERNAME AS SQLInstance,
	ls.primary_server,
	ls.primary_database,
	lsd.restore_delay,
	DATEDIFF(mi,lms.last_restored_date,GETDATE()) AS time_since_last_restore,
	lms.last_copied_date,
	lms.last_restored_date,
	lms.last_copied_file,
	lms.last_restored_file,
	lsd.disconnect_users,
	ls.backup_source_directory,
	ls.backup_destination_directory,
	ls.monitor_server,
	getdate() as collect_date
FROM msdb.dbo.log_shipping_secondary (NOLOCK) ls
	INNER JOIN msdb.dbo.log_shipping_secondary_databases (NOLOCK) lsd
	ON lsd.secondary_id=ls.secondary_id
	INNER JOIN msdb.dbo.log_shipping_monitor_secondary (NOLOCK) lms
	ON lms.secondary_id=lsd.secondary_id
