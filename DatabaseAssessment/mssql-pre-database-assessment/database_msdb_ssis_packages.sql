/*
#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

*/

/*
Author:       Marcos Freccia (mfreccia)
Date:         18/11/2021
Description:  Script to get ssis packages in MSDB
Permission:   db_datareader on msdb database
*/


SET NOCOUNT ON
;WITH ChildFolders
AS
(
SELECT PARENT.parentfolderid
											, PARENT.folderid
											, PARENT.foldername
											, CAST('' AS sysname) AS RootFolder
											, CAST(PARENT.foldername AS VARCHAR(MAX)) AS FullPath
											, 0 AS Lvl
									FROM msdb.dbo.sysssispackagefolders PARENT
									WHERE PARENT.parentfolderid IS NULL
									UNION ALL
									SELECT CHILD.parentfolderid
											, CHILD.folderid
											, CHILD.foldername
											, CASE ChildFolders.Lvl
												WHEN 0 THEN CHILD.foldername
													ELSE ChildFolders.RootFolder
												END AS RootFolder
											, CAST(ChildFolders.FullPath + '/' + CHILD.foldername AS VARCHAR(MAX)) as FullPath
											, ChildFolders.Lvl + 1 AS Lvl
									FROM msdb.dbo.sysssispackagefolders CHILD
										INNER JOIN ChildFolders ON ChildFolders.folderid = CHILD.parentfolderid
								)
								SELECT @@SERVERNAME as SQLInstance,F.RootFolder as 'RootFolder', F.FullPath as 'FullPath'
								 , P.name as 'PackageName'
								 , ISNULL(P.description,'') as 'Description',getdate() as collect_date
								FROM ChildFolders F
									INNER JOIN msdb.dbo.sysssispackages P
										ON P.folderid = F.folderid
								WHERE ISNULL(P.description,'') <> 'System Data Collector Package'
								ORDER BY F.FullPath ASC
											, P.name ASC;
