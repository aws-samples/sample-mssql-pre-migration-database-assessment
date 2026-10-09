/*
#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

*/
SELECT @@SERVERNAME AS SQLInstance
       ,USR.UserName AS SubscriptionOwner
      ,SUB.ModifiedDate
      ,SUB.[Description]
      ,SUB.EventType
      ,SUB.DeliveryExtension
      ,SUB.LastStatus
      ,SUB.LastRunTime
      ,SCH.NextRunTime
      ,SCH.Name AS ScheduleName
      ,CAT.[Path] AS ReportPath
      ,CAT.[Description] AS ReportDescription
      ,SUB.Parameters
      ,GETDATE() as collect_date
FROM dbo.Subscriptions AS SUB
     INNER JOIN dbo.Users AS USR
         ON SUB.OwnerID = USR.UserID
     INNER JOIN dbo.[Catalog] AS CAT
         ON SUB.Report_OID = CAT.ItemID
     INNER JOIN dbo.ReportSchedule AS RS
         ON SUB.Report_OID = RS.ReportID
            AND SUB.SubscriptionID = RS.SubscriptionID
     INNER JOIN dbo.Schedule AS SCH
         ON RS.ScheduleID = SCH.ScheduleID
ORDER BY USR.UserName
        ,CAT.[Path];
