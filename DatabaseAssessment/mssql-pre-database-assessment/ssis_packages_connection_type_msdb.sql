/*
#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

*/

/*
Author:       Marcos Freccia (mfreccia)
Date:         18/11/2021
Description:  Script to check any file system task is being used inside the SSIS Packages located in MSDB.
Permission:   db_datareader on msdb database
*/

USE msdb
GO
WITH
    XMLNAMESPACES('www.microsoft.com/SqlServer/Dts' as DTS)
,
    PackageDefinition
    as
    (
        SELECT spf.folderName, name, cast(cast(PackageData as varbinary(max))as xml) as PackageData
        FROM [dbo].[sysssispackages] as sp
            LEFT JOIN sysssispackagefolders as spf
            ON sp.folderid = spf.folderid
        WHERE spf.foldername <>'Data Collector'
    ),
    PackageConnectionStrings
    as
    (
        SELECT foldername, name
, conman.c.value('(./@DTS:ObjectName)[1]','varchar(250)') as ConnectionName
, conman.c.value('(./@DTS:CreationName)[1]','varchar(250)') as ConnectionType
, conman.c.value('(./DTS:ObjectData/DTS:ConnectionManager/@DTS:ConnectionString)[1]','varchar(max)')as ConnectionString
        FROM PackageDefinition
CROSS APPLY PackageData.nodes('/DTS:Executable/DTS:ConnectionManagers/DTS:ConnectionManager')as conman(c)
    ),
    ExtraComponents
    as
    (
        SELECT foldername, name
, conman.c.value('(./@DTS:ObjectName)[1]','varchar(250)') as ConnectionName
, conman.c.value('(./@DTS:ExecutableType)[1]','varchar(250)') as TaskType
        FROM PackageDefinition
CROSS APPLY PackageData.nodes('/DTS:Executable/DTS:Executables/DTS:Executable')as conman(c)
    )
    SELECT DISTINCT @@SERVERNAME as SQLInstance, foldername as FolderName, name as PackageName, ConnectionType, 'N/A' as TaskType,
        GETDATE() as collect_date
    FROM PackageConnectionStrings
    where ConnectionType IN('FLATFILE',
'ADO.NET:System.Data.SqlClient.SqlConnection, System.Data, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089',
'FILE','EXCEL','HTTP')
UNION
    SELECT DISTINCT @@SERVERNAME as SQLInstance, foldername as FolderName, name as PackageName, 'N/A' as ConnectionType, TaskType,
        GETDATE() as collect_date
    FROM ExtraComponents
    WHERE TaskType NOT IN ('Microsoft.ASExecuteDDLTask','Microsoft.DTSProcessingTask','Microsoft.BulkInsertTask',
'Microsoft.DbMaintenanceCheckIntegrityTask','Microsoft.Pipeline','Microsoft.DMQueryTask','Microsoft.ExecuteSQLTask',
'STOCK:FOREACHLOOP','Microsoft.DataProfilingTask','Microsoft.ExecutePackageTask','Microsoft.DbMaintenanceExecuteAgentJobTask',
'Microsoft.DbMaintenanceTSQLExecuteTask','Microsoft.DbMaintenanceNotifyOperatorTask','Microsoft.DbMaintenanceReindexTask',
'Microsoft.DbMaintenanceDefragmentIndexTask','Microsoft.DbMaintenanceShrinkTask','Microsoft.TransferDatabaseTask','Microsoft.TransferJobsTask',
'Microsoft.TransferLoginsTask','Microsoft.TransferSqlServerObjectsTask','Microsoft.DbMaintenanceUpdateStatisticsTask','STOCK:SEQUENCE',
'STOCK:FOREACHLOOP','STOCK:FORLOOP','SSIS.Pipeline.3','Microsoft.TransferObjectsTask')
        AND TaskType NOT LIKE 'Microsoft.SqlServer.Dts.Tasks.ExecuteSQLTask.ExecuteSQLTask%'
ORDER BY @@SERVERNAME, foldername, name
