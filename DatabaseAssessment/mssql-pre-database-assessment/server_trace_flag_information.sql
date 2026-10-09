/*
#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

*/

/*
Author: 		Marcos Freccia (mfreccia)
Date: 			29/11/2022
Description: 	Script to retrieve the trace flags in place
Permission:     VIEW SERVER STATE
*/

SET NOCOUNT ON;
-- Requires membership in the public role.
CREATE TABLE #tracestatus
(
    TraceFlag INT,
    Status INT,
    Global INT,
    Session INT
);

INSERT INTO #tracestatus
(
    TraceFlag,
    Status,
    Global,
    Session
)
EXEC ('DBCC TRACESTATUS (-1)');

SELECT	@@SERVERNAME as SQLInstance,
	   TraceFlag,
       Status,
       Global,
       Session,
	   getdate() as collect_date
FROM #tracestatus;

DROP TABLE #tracestatus;
SET NOCOUNT OFF;
