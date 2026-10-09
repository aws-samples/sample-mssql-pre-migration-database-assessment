/*
#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

*/

/*
Author: 		 Marcos Freccia (mfreccia)
Date: 			 29/11/2022
Description: Script to collect reporting services information
Permission:  db_datareader on the report server database
*/

DECLARE @SQLBuild INT = 0,
        @STRSQL VARCHAR(MAX);
SELECT @SQLBuild
    = SUBSTRING(
                   CAST(SERVERPROPERTY('productversion') AS VARCHAR),
                   0,
                   CHARINDEX('.', CAST(SERVERPROPERTY('productversion') AS VARCHAR))
               );
IF (@SQLBuild) > 13
BEGIN
SET @STRSQL = 'SELECT @@SERVERNAME AS SQLInstance,
  ItemID -- Unique Identifier
, [Path] --Path including object name
, [Name] --Just the objectd name
, ISNULL(CAST(ParentID as NVARCHAR(512)),''----'') as ParentID
, CASE [Type] --Type, an int which can be converted using this case statement.
    WHEN 1 THEN ''Folder''
    WHEN 2 THEN ''Report''
    WHEN 3 THEN ''File''
    WHEN 4 THEN ''Linked Report''
    WHEN 5 THEN ''Data Source''
    WHEN 6 THEN ''Report Model - Rare''
    WHEN 7 THEN ''Report Part - Rare''
    WHEN 8 THEN ''Shared Data Set - Rare''
    WHEN 9 THEN ''Image''
    ELSE CAST(Type as varchar(100))
  END AS TypeName
--, content
, ISNULL(CAST(LinkSourceID as NVARCHAR(512)),''----'') as LinkSourceID
, ISNULL([Description],''N/A'') as Description --This is the same information as can be found in the GUI
, ISNULL([Hidden],0) as [Hidden] --Is the object hidden on the screen or not
, CreatedBy.UserName CreatedBy
, CreationDate
, ModifiedBy.UserName ModifiedBy
, ModifiedBy.ModifiedDate
, GETDATE() as collect_date
FROM dbo.[Catalog] (NOLOCK) CTG
  INNER JOIN dbo.Users (NOLOCK) CreatedBy ON CTG.CreatedByID = CreatedBy.UserID
  INNER JOIN dbo.Users (NOLOCK) ModifiedBy ON CTG.ModifiedByID = ModifiedBy.UserID;'
EXEC (@STRSQL);
END;
ELSE
BEGIN
SET @STRSQL = 'SELECT @@SERVERNAME AS SQLInstance,
  ItemID -- Unique Identifier
, [Path] --Path including object name
, [Name] --Just the objectd name
, ISNULL(CAST(ParentID as NVARCHAR(512)),''----'') as ParentID
, CASE [Type] --Type, an int which can be converted using this case statement.
    WHEN 1 THEN ''Folder''
    WHEN 2 THEN ''Report''
    WHEN 3 THEN ''File''
    WHEN 4 THEN ''Linked Report''
    WHEN 5 THEN ''Data Source''
    WHEN 6 THEN ''Report Model - Rare''
    WHEN 7 THEN ''Report Part - Rare''
    WHEN 8 THEN ''Shared Data Set - Rare''
    WHEN 9 THEN ''Image''
    ELSE CAST(Type as varchar(100))
  END AS TypeName
--, content
, ISNULL(CAST(LinkSourceID as NVARCHAR(512)),''----'') as LinkSourceID
, ISNULL([Description],''N/A'') --This is the same information as can be found in the GUI
, ISNULL([Hidden],0) as [Hidden] --Is the object hidden on the screen or not
, CreatedBy.UserName CreatedBy
, CreationDate
, ''---''ModifiedBy
, ''1900-01-01'' as ModifiedDate
, GETDATE() as collect_date
FROM dbo.[Catalog] (NOLOCK) CTG
  INNER JOIN dbo.Users (NOLOCK) CreatedBy ON CTG.CreatedByID = CreatedBy.UserID'
EXEC (@STRSQL);
END
