/*
#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

*/

/*
Author: 		Marcos Freccia (mfreccia)
Date: 			29/11/2022
Description: 	Script to retrieve SQL Instance general information such as build levels, version, edition, etc..
Permission:     public role on master database
*/

SELECT TOP 1
       @@SERVERNAME as SQLInstance,
       create_date AS 'InstallDate',
	   (SELECT sqlserver_start_time FROM sys.dm_os_sys_info) as SQLServerStartTime,
       SERVERPROPERTY('Edition') AS 'SQLServerEdition',
       SERVERPROPERTY('ProductLevel') AS 'ProductLevel',
       SERVERPROPERTY('ProductUpdateLevel') AS 'ProductUpdateLevel',
       SERVERPROPERTY('Collation') AS 'Collation',
       SERVERPROPERTY('productversion') AS 'ProductBuildLevel',
       CASE
           WHEN CONVERT(VARCHAR(128), SERVERPROPERTY('productversion')) LIKE '8%' THEN
               'SQL Server 2000'
           WHEN CONVERT(VARCHAR(128), SERVERPROPERTY('productversion')) LIKE '9%' THEN
               'SQL Server 2005'
           WHEN CONVERT(VARCHAR(128), SERVERPROPERTY('productversion')) LIKE '10.0%' THEN
               'SQL Server 2008'
           WHEN CONVERT(VARCHAR(128), SERVERPROPERTY('productversion')) LIKE '10.5%' THEN
               'SQL Server 2008 R2'
           WHEN CONVERT(VARCHAR(128), SERVERPROPERTY('productversion')) LIKE '11%' THEN
               'SQL Server 2012'
           WHEN CONVERT(VARCHAR(128), SERVERPROPERTY('productversion')) LIKE '12%' THEN
               'SQL Server 2014'
           WHEN CONVERT(VARCHAR(128), SERVERPROPERTY('productversion')) LIKE '13%' THEN
               'SQL Server 2016'
           WHEN CONVERT(VARCHAR(128), SERVERPROPERTY('productversion')) LIKE '14%' THEN
               'SQL Server 2017'
           WHEN CONVERT(VARCHAR(128), SERVERPROPERTY('productversion')) LIKE '15%' THEN
               'SQL Server 2019'
           WHEN CONVERT(VARCHAR(128), SERVERPROPERTY('productversion')) LIKE '16%' THEN
               'SQL Server 2022'
           ELSE
               'unknown'
       END AS 'SQLServerMajorVersion',
	   SERVERPROPERTY('IsClustered') AS 'IsClustered',
	   SERVERPROPERTY('IsHadrEnabled') AS 'IsHadrEnabled',
       ISNULL(SERVERPROPERTY ('IsPolyBaseInstalled'),0) AS IsPolyBaseInstalled,
	   SUBSTRING(@@VERSION,CHARINDEX('Windows',@@VERSION,0),100) AS OSVersion,
	   GETDATE() as collect_date
FROM sys.server_principals (NOLOCK)
WHERE name = 'NT SERVICE\MSSQLSERVER'
      OR name = 'NT AUTHORITY\SYSTEM'
ORDER BY create_date DESC;
