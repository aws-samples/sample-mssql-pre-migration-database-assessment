/*
#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

*/

/*
Author: 		Marcos Freccia (mfreccia)
Date: 			29/11/2022
Description: 	Script to identify environment variables created on the SSISDB
Permission:     ssis_admin on SSISDB
*/


SELECT
	@@SERVERNAME AS SQLInstance,
	f.[name] as 'FolderName',
	e.[name] as 'EnvironmentName',
    v.[name] as 'VariableName'
   ,v.[type] as 'DataType'
   ,v.[value] as 'Value'
   ,e.created_by_name as CreatedByName
   ,getdate() as collect_date
FROM [SSISDB].[catalog].[environments]  (NOLOCK) e
INNER JOIN [SSISDB].[catalog].[folders] (NOLOCK) f
     ON f.[folder_id] = e.[folder_id]
JOIN [SSISDB].[catalog].[environment_variables] (NOLOCK) v
	 ON e.[environment_id] = v.[environment_id]
