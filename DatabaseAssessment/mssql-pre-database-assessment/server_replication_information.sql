/*
#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

*/

/*
Author: 		Marcos Freccia (mfreccia)
Date: 			29/11/2022
Description: 	Script to collect replication information
Permission:     public permission on the distributor database
*/

SELECT @@SERVERNAME as SQLInstance,
	   publisher_id,
       publisher_db,
       publication AS PublicationName,
       CASE
           WHEN publication_type = 0 THEN
               'Transactional Replication'
           WHEN publication_type = 1 THEN
               'SnapshotReplication'
           WHEN publication_type = 2 THEN
               'Merge Replication'
       END AS ReplicationType,
       vendor_name AS VendorName,
       description AS ReplicationDescription
	   ,getdate() as collect_date
FROM dbo.MSpublications;
