/*
#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

*/

/*
Author: 	 Marcelo Fernandes (marcesl)
Date: 		 01/10/2021
Description: Script to list SQL Server Maintenance plans
Permission:  db_datareader on msdb database
*/
--Getting all maintance plan details
declare  @xml table (sno xml NULL,
	MaintenancePlan sysname NOT NULL,
	Description nvarchar(1024) NULL,
	PlanOwner nvarchar(128) NULL,
	SubplanName sysname NOT NULL,
	SubplanDescription nvarchar(512) NULL,
	JobName sysname NOT NULL,
	JobDescription nvarchar(512) NULL,
	enabled bit)
;with cte_active_jobs as (
select
	p.name as 'MaintenancePlan'
	,p.[description] as 'Description'
	,p.[owner] as 'PlanOwner'
	,sp.subplan_name as 'SubplanName'
	,sp.subplan_description as 'SubplanDescription'
	,j.name as 'JobName'
	,j.[description] as 'JobDescription'
	,j.[enabled]
from msdb.dbo.sysmaintplan_plans (NOLOCK) p
	INNER JOIN msdb.dbo.sysmaintplan_subplans (NOLOCK) sp
	on p.id = sp.plan_id
	INNER JOIN msdb.dbo.sysjobs (NOLOCK) j
	on sp.job_id = j.job_id
), maintenance_det as (
SELECT CAST(CAST([packagedata] as varbinary(max)) as xml) as sno,b.*
FROM msdb.dbo.sysssispackages (NOLOCK) A
INNER JOIN cte_active_jobs b
ON a.name = b.MaintenancePlan
)

insert into @xml
select * from maintenance_det

;WITH XMLNAMESPACES ('www.microsoft.com/SqlServer/Dts' as p1,
  'www.microsoft.com/SqlServer/Dts' as DTS,
  'www.microsoft.com/sqlserver/dts/tasks/sqltask' as SQLTask)
SELECT @@SERVERNAME AS SQLInstance,
	MaintenancePlan,
	Description,
	PlanOwner,
	SubplanName,
	SubplanDescription,
	JobName,
	JobDescription,enabled,
	d.b.value('./@DTS:refId[1]','varchar(200)') as [TaskName],
	C.a.value('./@SQLTask:DatabaseName[1]','varchar(20)') as [DatabaseName],
	getdate() as collect_date
 FROM @xml as sno CROSS APPLY sno.nodes('/DTS:Executable/DTS:Executables/DTS:Executable/DTS:Executables/DTS:Executable/DTS:ObjectData/SQLTask:SqlTaskData/SQLTask:SelectedDatabases') as c(a)
 CROSS APPLY sno.nodes('/DTS:Executable/DTS:Executables/DTS:Executable/DTS:Executables/DTS:Executable') d(b)
