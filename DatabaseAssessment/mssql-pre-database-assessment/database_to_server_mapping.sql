/*
#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

*/

/*
Author:         Marcos Freccia (mfreccia)
Date:           21/03/2024
Description:    Script to retrieve list databases and which servers are calling the databases
Permissions:	VIEW SERVER STATE

Author: 		Marcelo Fernandes (marcesl)
Date: 			03/04/2025
Description: 	adjusted for SQL 2008/2008R2
*/

DECLARE @SQLBuild DECIMAL(4,2) = 0,
        @STRSQL VARCHAR(MAX);
SELECT @SQLBuild = CAST(LEFT(CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(50)), 4) AS DECIMAL(4,2))
IF (@SQLBuild) > 10.50
BEGIN
    SET @STRSQL
        = '
SELECT
    @@SERVERNAME as SQLInstance,
    s.session_id,
    c.connect_time,
       s.host_name,
    s.program_name,
       DB_NAME(s.database_id) as DatabaseName,
    DB_NAME(s.authenticating_database_id) as AuthenticatingDatabaseName,
       s.login_name,
    c.net_transport,
    c.protocol_type,
    c.encrypt_option,
    c.auth_scheme,
       GETDATE() AS date_collected
FROM
    sys.dm_exec_connections AS c
LEFT JOIN
    sys.dm_exec_sessions AS s ON c.session_id = s.session_id
LEFT JOIN
    sys.dm_exec_requests AS r ON s.session_id = r.session_id
WHERE c.session_id > 50
AND c.session_id <> @@SPID';
    EXEC (@STRSQL);
END
ELSE
BEGIN
	SELECT
		@@SERVERNAME as SQLInstance,
		s.session_id,
		c.connect_time,
		   s.host_name,
		s.program_name,
		db_name(dbid) as DatabaseName,
		'null' as AuthenticatingDatabaseName,
		   s.login_name,
		c.net_transport,
		c.protocol_type,
		c.encrypt_option,
		c.auth_scheme,
		   GETDATE() AS date_collected
	FROM
	 sysprocesses p LEFT JOIN
		sys.dm_exec_sessions AS s ON p.spid = s.session_id
		left join sys.dm_exec_connections AS c ON c.session_id = p.spid
	WHERE c.session_id > 50	
		AND c.session_id <> @@SPID
END
