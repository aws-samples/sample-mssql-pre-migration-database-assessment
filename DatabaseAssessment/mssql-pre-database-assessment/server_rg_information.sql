/*
#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

*/

/*
Author: 	 Marcelo Fernandes (marcesl)
Date: 		 01/10/2021
Description: Script to describe Resource Governor details and configurations
Permission:  VIEW ANY DEFINITION
*/

IF(SELECT is_enabled
FROM sys.resource_governor_configuration (NOLOCK))=0
	SELECT @@SERVERNAME as SQLInstance, is_enabled, COALESCE(OBJECT_NAME(classifier_function_id),CAST(classifier_function_id AS VARCHAR)) AS classifier
	 , null AS pool_name, null AS group_name, null AS importance, -1 AS request_max_memory_grant_percent, -1 AS request_max_cpu_time_sec, -1 AS min_memory_percent, -1 AS max_memory_percent, -1 AS min_cpu_percent, -1 AS max_cpu_percent, getdate() as collect_date
FROM sys.resource_governor_configuration (NOLOCK)
ELSE
	SELECT CAST(SERVERPROPERTY('MachineName') AS VARCHAR(128)) AS Hostname,
	CAST(coalesce(SERVERPROPERTY('INSTANCENAME'),'MSQLSERVER') AS VARCHAR(128)) AS InstanceName,
	(SELECT is_enabled
	FROM sys.resource_governor_configuration (NOLOCK)) AS is_enabled,
	(SELECT COALESCE(OBJECT_NAME(classifier_function_id),CAST(classifier_function_id AS VARCHAR))
	FROM sys.resource_governor_configuration (NOLOCK)) AS classifier,
	rgp.name AS pool_name,
	rgg.name AS group_name,
	rgg.importance, ISNULL(rgg.request_max_memory_grant_percent,-1) as request_max_memory_grant_percent, ISNULL(rgg.request_max_cpu_time_sec,-1) as request_max_cpu_time_sec, ISNULL(rgp.min_memory_percent,-1) as min_memory_percent, ISNULL(rgp.max_memory_percent,-1) as max_memory_percent, ISNULL(rgp.min_cpu_percent,-1)as min_cpu_percent, ISNULL(rgp.max_cpu_percenT,-1) as max_cpu_percenT, getdate() as collect_date
FROM sys.resource_governor_resource_pools (NOLOCK) AS rgp
	INNER JOIN sys.resource_governor_workload_groups (NOLOCK) As rgg
	ON rgp.pool_id = rgg.pool_id
WHERE rgg.group_id > 2
