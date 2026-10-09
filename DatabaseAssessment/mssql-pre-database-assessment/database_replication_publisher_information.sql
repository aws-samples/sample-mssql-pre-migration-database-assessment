/*
#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

*/

/*
Author: 		Marcos Freccia (mfreccia)
Date: 			29/11/2022
Description: 	Script to collect replication information on the publisher database
Permission:     db_datareader on the publisher database
*/

SELECT @@SERVERNAME AS SQLInstance,
	DB_NAME() AS PublisherDatabase
, sp.name AS PublicationName
, sa.dest_owner AS SchemaName
, sa.name AS TableName
, UPPER(srv.srvname) AS SubscriberServerName
,GETDATE() AS collect_date
FROM dbo.syspublications (NOLOCK) sp
JOIN dbo.sysarticles (NOLOCK) sa ON sp.pubid = sa.pubid
JOIN dbo.syssubscriptions (NOLOCK) s ON sa.artid = s.artid
JOIN master.dbo.sysservers (NOLOCK) srv ON s.srvid = srv.srvid
