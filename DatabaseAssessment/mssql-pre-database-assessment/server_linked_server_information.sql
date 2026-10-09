/*
#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

*/

/*
Author: 		Marcos Freccia (mfreccia)
Date: 			29/11/2022
Description: 	Script to collect linked servers
Permission:     public


Author: 		Marcelo Fernandes (marcesl)
Date: 			03/04/2025
Description: 	Fixed issue when deleting linked server where linkedserver has same name as source server
*/


-- Returns Linked Server Information
SET NOCOUNT ON
IF OBJECT_ID('tempdb..#LinkedServers') IS NOT NULL DROP TABLE #LinkedServers;

CREATE TABLE #LinkedServers(SQLInstance varchar(50),LinkedServerName varchar(100),ProviderName VARCHAR(100),
Product VARCHAR(50),DataSource VARCHAR(50),ProviderString varchar(256),Location varchar(256),category varchar(256),
collect_date datetime)

INSERT #LinkedServers (LinkedServerName,ProviderName,Product,DataSource,ProviderString,Location,category)
EXEC sp_linkedservers

UPDATE #LinkedServers SET SQLInstance = @@SERVERNAME, collect_date = GETDATE()

SELECT L.* FROM #LinkedServers L LEFT JOIN sys.servers S ON L.LinkedServerName = S.name
where S.server_id > 0
