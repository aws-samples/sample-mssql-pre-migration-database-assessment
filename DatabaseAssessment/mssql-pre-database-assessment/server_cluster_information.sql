/*
#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

*/

/*
Author:      Marcos Freccia (mfreccia)
Date:        29/11/2022
Description: Script to check if Server is in Windows Server Failover Cluster (WSFC), if so, it returns the cluster nodes.
Permission:  VIEW SERVER STATE
*/
DECLARE @SQLCluster sql_variant
SELECT @SQLCluster = SERVERPROPERTY('IsClustered')


if(@SQLCluster >=1)
BEGIN
	SELECT @@SERVERNAME as SQLInstance,
		NodeName,
		getdate() as collect_date
	FROM sys.dm_os_cluster_nodes
END
