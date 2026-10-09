/*
#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

*/

/*
Author:         Marcos Freccia (mfreccia)
Date:           25/11/2022
Description:    Script to retrieve database mail configuration
Permissions:	db_datareader on msdb database
*/

SELECT @@SERVERNAME AS SQLInstance,
		p.name AS 'ProfileName',
       p.description AS 'ProfileDescription',
       p.last_mod_datetime AS 'LastModificationDate',
       p.last_mod_user AS 'LastModificationUser',
       a.account_id AS 'AccountID',
       a.name AS 'AccountName',
       a.description AS 'AccountDescription',
       a.email_address AS 'EmailAddress',
       a.display_name AS 'DisplayName',
       a.replyto_address AS 'ReplyToAddress',
       s.servertype AS 'ServerType',
       s.servername AS 'ServerName',
       s.port AS 'Port',
       s.username AS 'Username',
       s.enable_ssl AS 'SSLEnabled',
	   getdate() as collect_date
FROM msdb.dbo.sysmail_profile (NOLOCK) p
    JOIN msdb.dbo.sysmail_profileaccount (NOLOCK) pa
        ON p.profile_id = pa.profile_id
    JOIN msdb.dbo.sysmail_account (NOLOCK) a
        ON pa.account_id = a.account_id
    JOIN msdb.dbo.sysmail_server (NOLOCK) s
        ON a.account_id = s.account_id;
