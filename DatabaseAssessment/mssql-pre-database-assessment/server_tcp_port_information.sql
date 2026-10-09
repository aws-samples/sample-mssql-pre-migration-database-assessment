/*
#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

*/

/*
Author: 		Marcos Freccia (mfreccia)
Date: 			28/10/2021
Description: 	Script list the TCP Ports used. This will help on the automation for deploying RDS Instances with the correct TCP Port
Permission:     VIEW SERVER STATE
*/
SELECT DISTINCT @@SERVERNAME AS SQLInstance,
net_transport,protocol_type,encrypt_option,
auth_scheme,
client_net_address,
ISNULL(local_tcp_port,-1) as local_tcp_port,
GETDATE() as collect_date
FROM sys.dm_exec_connections (NOLOCK)
WHERE net_transport <> 'Shared memory' and protocol_type <> 'Database Mirroring'
AND session_id <> @@SPID
