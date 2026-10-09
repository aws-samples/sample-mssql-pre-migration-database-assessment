/*
#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

*/

/*
Author: 	 Marcelo Fernandes (marcesl)
Date: 		 01/10/2021
Description: Script to retrieve service broker information
Permission:  public on the user database

*/

SELECT @@SERVERNAME as SQLInstance,
    name, type,
    create_date,
    modify_date,
    GETDATE() AS collect_date
FROM sys.service_queues (NOLOCK)
WHERE is_ms_shipped = 0
