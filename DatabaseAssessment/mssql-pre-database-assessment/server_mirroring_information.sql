/*
#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

*/

/*
Author: 		Marcos Freccia (mfreccia)
Date: 			29/11/2022
Description: 	Script to collect database mirroring information
Permission:     VIEW ANY DATABASE
*/


SELECT  @@SERVERNAME as SQLInstance,
		DB_NAME(database_id) AS DatabaseName,
       mirroring_state_desc AS MirroringState,
       mirroring_role_desc AS MirroringRole,
       mirroring_safety_level_desc AS MirroringSafetyLevel,
       mirroring_partner_name AS MirroringPartnerName,
       mirroring_partner_instance AS MirroringPartnerInstance,
       mirroring_witness_state_desc AS MirroringWitnessState,
	   getdate() as collect_date
FROM sys.database_mirroring (NOLOCK)
WHERE mirroring_state IS NOT NULL;
