/*
#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

*/

/*
Author:         Jose Amado Blanco (joseambl)
Date:           05/12/2022
Description:    Script to retrieve any features that could prevent a downgrade from SQL Server Enterprise to Standard Edition
Permissions:	VIEW DATABASE STATE
*/

SELECT @@SERVERNAME as SQLInstance,
DB_NAME() as DatabaseName,
feature_name as FeatureName,
getdate() as date_collect
FROM sys.dm_db_persisted_sku_features (NOLOCK)
