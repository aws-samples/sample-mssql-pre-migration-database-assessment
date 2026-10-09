/*
#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

*/

/*
Author: 	 Marcelo Fernandes (marcesl)
Date: 		 01/10/2021
Description: Script to retrieve the list of jobs
Permission:  db_datareader on msdb database
*/


SELECT
  @@SERVERNAME as SQLInstance,
  job.name as JobName
, job.enabled
, job.description
, SUSER_SNAME(job.owner_sid) as JobOwner
, cat.name as JobCategoryName
, job_step.step_id
, job_step.step_name
, job_step.subsystem
, job_step.database_name
, job_step.command
, CASE on_success_action
    WHEN 1 THEN 'Quit with success'
    WHEN 2 THEN 'Quit with failure'
    WHEN 3 THEN 'Go to next step'
    WHEN 4 THEN 'Go to step ' + CAST(on_success_step_id AS VARCHAR(3))
  END On_Success
, CASE on_fail_action
    WHEN 1 THEN 'Quit with success'
    WHEN 2 THEN 'Quit with failure'
    WHEN 3 THEN 'Go to next step'
    WHEN 4 THEN 'Go to step ' + CAST(on_fail_step_id AS VARCHAR(3))
  END On_Failure,
  job.notify_level_eventlog
 , job.notify_level_email,
  job.notify_email_operator_id
, job.delete_level,
  getdate() as collect_date
FROM msdb.dbo.sysjobs (NOLOCK) as job
  INNER JOIN msdb.dbo.syscategories (NOLOCK) as cat
  on job.category_id = cat.category_id
  INNER JOIN msdb.dbo.sysjobsteps (NOLOCK) job_step
  ON job.job_id = job_step.job_id
WHERE job.name not in ('syspolicy_purge_history')
ORDER BY date_created
