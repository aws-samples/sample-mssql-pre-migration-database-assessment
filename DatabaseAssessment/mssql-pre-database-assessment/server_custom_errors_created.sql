/*
#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

*/

/*
Author:         Marcos Freccia (mfreccia)
Date:           25/11/2022
Description:    Script to return information about custom error messages created in the instance
Permission:     Requires membership in the public role.
*/

SET NOCOUNT ON
SELECT @@SERVERNAME AS SQLInstance,description as 'Message', error as 'ErrorID',
msglangid as 'LanguageID', severity as 'ErrorSeverity',getdate() as collect_date
FROM master.dbo.sysmessages (NOLOCK)
WHERE Error > 50000
