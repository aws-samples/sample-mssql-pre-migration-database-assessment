/*
#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

*/

/*
Author: 		Marcos Freccia (mfreccia)
Date: 			28/10/2021
Description: 	Script to return if Service Broker Endpoints or TCP Endpoints are detected
Permission:     VIEW SERVER STATE
*/

SELECT @@SERVERNAME AS SQLInstance,
name AS EndpointName, protocol_desc,
GETDATE() AS collect_date
FROM sys.tcp_endpoints (NOLOCK)
WHERE type IN(3,2) AND name NOT IN ('Dedicated Admin Connection','TSQL Default TCP');
