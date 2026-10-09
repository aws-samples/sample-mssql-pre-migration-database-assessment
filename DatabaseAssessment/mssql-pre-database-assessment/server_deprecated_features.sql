/*
#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

*/

/*
Author:      Marcos Freccia (mfreccia)
Date:        25/11/2022
Description: Script provides a counter to monitor the features designated as deprecated. provides a usage count that lists the number of times the deprecated feature was encountered since SQL Server last started.
Permissions: VIEW SERVER STATE
*/

SELECT
  @@SERVERNAME AS SQLInstance,
  RTRIM(instance_name) 'DeprecatedFeature',
  cntr_value 'UsageCount',
  getdate() as collect_date
FROM sys.dm_os_performance_counters (NOLOCK)
WHERE object_name = 'SQLServer:Deprecated Features'
AND cntr_value > 0;
