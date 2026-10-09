/*
#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

*/

/*
Author:      Marcelo Fernandes (marcesl)
Date:        10/04/2021
Description: Script to check if database is using TDE, will list all encrypted database with details on certificate.
Permission:  VIEW SERVER STATE
*/
SELECT  @@SERVERNAME AS SQLInstance,
    database_name = d.name,
    cert_name = c.name,
	encryption_state_desc = CASE encryption_state
         WHEN '0'  THEN  'No database encryption key present, no encryption'
         WHEN '1'  THEN  'Unencrypted'
         WHEN '2'  THEN  'Encryption in progress'
         WHEN '3'  THEN  'Encrypted'
         WHEN '4'  THEN  'Key change in progress'
         WHEN '5'  THEN  'Decryption in progress'
         WHEN '6'  THEN  'Protection change in progress (The certificate or asymmetric key that is encrypting the database encryption key is being changed.)'
         ELSE 'No Status'
         END,
	dek.key_algorithm,
	dek.key_length,
	getdate() as collect_date
FROM sys.dm_database_encryption_keys (NOLOCK) dek
LEFT JOIN sys.certificates (NOLOCK) c
ON dek.encryptor_thumbprint = c.thumbprint
INNER JOIN sys.databases (NOLOCK) d
ON dek.database_id = d.database_id;
