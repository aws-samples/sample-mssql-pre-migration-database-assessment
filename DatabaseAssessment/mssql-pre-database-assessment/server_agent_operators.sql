/*
#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

*/

/*
Author:         Marcos Freccia (mfreccia)
Date:           25/11/2022
Description:    Script to get SQL Server Agent Operator information
Permission:     db_datareader on MSDB
*/

SET NOCOUNT ON
SELECT @@SERVERNAME AS SQLInstance
, name
, enabled
, email_address
, last_email_date
, last_email_time
, getdate() AS collect_date
FROM msdb.dbo.sysoperators (NOLOCK)
