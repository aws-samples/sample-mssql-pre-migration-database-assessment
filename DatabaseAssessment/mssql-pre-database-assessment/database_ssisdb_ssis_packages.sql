/*
#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

*/

/*
Author:       Marcos Freccia (mfreccia)
Date:         18/11/2021
Description:  Script to get ssis packages in SSISDB
Permission:   db_datareader on SSISDB database
*/


SELECT @@SERVERNAME as SQLInstance,
    fd.name as FolderName,
    prj.[name] 'ProjectName',
    pkg.[name] as 'PackageName',
    pkg.[description] as 'Description',
    deployed_by_name as 'DeployedBy',
    last_deployed_time as 'LastDeploymentTime',
    prj.created_time as 'CreatedTime',
    GETDATE() as collect_date
FROM [catalog].[packages] (NOLOCK) as pkg
    INNER JOIN [catalog].[projects] (NOLOCK) prj
    ON pkg.[project_id] = prj.[project_id]
    INNER JOIN catalog.folders (NOLOCK) as fd
    ON fd.folder_id = prj.folder_id
ORDER BY pkg.[name]
