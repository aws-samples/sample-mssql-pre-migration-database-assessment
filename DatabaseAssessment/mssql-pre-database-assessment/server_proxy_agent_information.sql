/*
#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

*/

/*
Author: 		Marcos Freccia (mfreccia)
Date: 			29/11/2022
Description: 	Script to collect proxy information and what jobs use them.
Permission:     db_datareader on `msdb`
*/


SET NOCOUNT ON
SELECT @@SERVERNAME as SQLInstance
, p.proxy_id as ProxyID
, p.name as ProxyName
, p.credential_id as CredentialID
, c.credential_identity as CredentialIdentity
, ISNULL(js.step_id,-1) as JobStepID
, js.step_name as StepName
, j.name  as JobName
, getdate() as collect_date
FROM msdb.dbo.sysproxies p
INNER JOIN master.sys.credentials (NOLOCK) c
ON p.credential_id = c.credential_id
LEFT OUTER JOIN msdb.dbo.sysjobsteps (NOLOCK) js
ON p.proxy_id = js.proxy_id
LEFT OUTER JOIN msdb.dbo.sysjobs (NOLOCK) j
ON js.job_id = j.job_id
