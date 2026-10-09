/*
#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

*/

/*
Author: 	 Marcelo Fernandes (marcesl)
Date: 		 01/10/2021
Description: Script to describe the AG configurations
Permission:  VIEW SERVER STATE, VIEW ANY DATABASE, VIEW ANY DEFINITION
*/


DECLARE @SQLBuild int=0, @STRSQL varchar(600)
SELECT @SQLBuild = SUBSTRING(CAST(SERVERPROPERTY('productversion') AS VARCHAR),0,charindex('.',CAST(SERVERPROPERTY('productversion') AS VARCHAR)))

if(@SQLBuild)>11
BEGIN
	SELECT @@SERVERNAME AS SQLInstance,
		ar.replica_server_name,
		agl.dns_name AS 'Listener',
		agl.port AS 'Listener_port',
		agli.state_desc as 'Listener_state',
		adc.database_name,
		ag.name AS ag_name,
		ag.automated_backup_preference_desc,
		ars.role_desc,
		drs.synchronization_state_desc,
		ar.availability_mode_desc,
		ar.failover_mode_desc,
		ar.primary_role_allow_connections_desc,
		ar.secondary_role_allow_connections_desc,
		drs.is_commit_participant,
		drs.synchronization_health_desc,
		drs.last_commit_time,
		getdate() as collect_date
	FROM sys.dm_hadr_database_replica_states AS drs
		INNER JOIN sys.availability_databases_cluster AS adc
		ON drs.group_id = adc.group_id AND
			drs.group_database_id = adc.group_database_id
		INNER JOIN sys.availability_groups AS ag
		ON ag.group_id = drs.group_id
		INNER JOIN sys.availability_replicas AS ar
		ON drs.group_id = ar.group_id AND
			drs.replica_id = ar.replica_id
		INNER JOIN sys.dm_hadr_availability_group_states AS hags
		ON hags.group_id = ag.group_id
		INNER JOIN sys.dm_hadr_availability_replica_states AS ars
		ON drs.group_id = ars.group_id AND
			drs.replica_id = ars.replica_id
		INNER JOIN sys.availability_group_listeners AS agl
		ON drs.group_id = ars.group_id
		INNER JOIN sys.availability_group_listener_ip_addresses AS agli
		ON agl.listener_id = agli.listener_id
	ORDER BY
	ag.name,
	ar.replica_server_name,
	adc.database_name;
END
