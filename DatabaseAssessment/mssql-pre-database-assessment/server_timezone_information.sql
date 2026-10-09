/*
#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

*/

/*
Author:      Marcos Freccia (mfreccia)
Date:        29/11/2022
Description: Script to retrieve timezone of the server
Permission:  sysadmin
*/

DECLARE @TimeZone VARCHAR(50)
EXEC MASTER.dbo.xp_regread 'HKEY_LOCAL_MACHINE',
'SYSTEM\CurrentControlSet\Control\TimeZoneInformation',
'TimeZoneKeyName',@TimeZone OUT
SELECT @@SERVERNAME as SQLInstance,@TimeZone as TimezoneConfiguration,getdate() as collect_date
