/*
#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

*/

/*
Author:         Marcos Freccia (mfreccia)
Date:           25/11/2022
Description:    Get a count of SQL connections by IP address
Permission:     Everyone can see their own session information.
                SQL Server: Requires VIEW SERVER STATE permission on SQL Server to see all sessions on the server.
                SQL Database: Requires VIEW DATABASE STATE to see all connections to the current database.
                VIEW DATABASE STATE cannot be granted in the master database.
*/

SELECT @@SERVERNAME AS SQLInstance,
ec.client_net_address as ClientAddress, es.[program_name] as ProgramName,
es.[host_name] as HostName, es.login_name as LoginName,
COUNT(ec.session_id) AS ConnectionCount,getdate() as collect_date
FROM sys.dm_exec_sessions AS es WITH (NOLOCK)
INNER JOIN sys.dm_exec_connections AS ec WITH (NOLOCK)
ON es.session_id = ec.session_id
GROUP BY ec.client_net_address, es.[program_name], es.[host_name], es.login_name
ORDER BY ec.client_net_address, es.[program_name] OPTION (RECOMPILE);
