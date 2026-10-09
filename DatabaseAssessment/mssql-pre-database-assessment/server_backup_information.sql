/*
#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

*/

/*
Author:         Marcos Freccia (mfreccia)
Date:           25/11/2022
Description:    Script to retrieve backup information for the last 10 days.
Permission:     db_datareader on MSDB
*/

;WITH
    backup_cte
    AS
    (
        SELECT database_name,
            backup_type = CASE type
                             WHEN 'D' THEN
                                 'Full Backup'
                             WHEN 'L' THEN
                                 'Transaction Log'
                             WHEN 'I' THEN
                                 'Differential Backup'
                             ELSE
                                 'other'
                         END,
            backup_start_date,
            backup_finish_date,
            backup_size,
            rownum = ROW_NUMBER() OVER (PARTITION BY database_name, type ORDER BY backup_finish_date DESC)
        FROM msdb.dbo.backupset (NOLOCK)
        WHERE (CONVERT(datetime, msdb.dbo.backupset.backup_start_date, 102) >= GETDATE() - 10)
    )
-- last 10 days. It can be modified if necessary
SELECT @@SERVERNAME AS SQLInstance,
    database_name AS DatabaseName,
    backup_type AS BackupType,
    backup_start_date AS BackupStartDate,
    backup_finish_date AS BackupFinishDate,
    DATEDIFF(MINUTE,backup_start_date,backup_finish_date) as TotalBackupTimeMinutes,
    backup_size AS BackupSize,
    CAST(backup_size/1024/1024 as DECIMAL(10,2)) AS BackupSizeMB
	   , getdate() as collect_date
FROM backup_cte
WHERE rownum = 1
ORDER BY database_name;
