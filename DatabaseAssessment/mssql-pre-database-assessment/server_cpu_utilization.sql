/*
#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

*/

/*
Author:         Jose Amado Blanco (joseambl)
Date:           05/12/2022
Description:    Script to retrieve cpu utilization FROM the host for the last 4 hours
Permissions:	VIEW SERVER STATE

*/


DECLARE @ts_now bigint
SELECT @ts_now = cpu_ticks / ( cpu_ticks / ms_ticks )
FROM sys.dm_os_sys_info
SELECT TOP (1000)
    @@SERVERNAME as SQLInstance
      , record_id
      , EventTime
      , CASE
           WHEN system_cpu_utilization_post_sp2 IS NOT NULL THEN
               system_cpu_utilization_post_sp2
           ELSE
               system_cpu_utilization_pre_sp2
       END AS system_cpu_utilization
      , CASE
           WHEN sql_cpu_utilization_post_sp2 IS NOT NULL THEN
               sql_cpu_utilization_post_sp2
           ELSE
               sql_cpu_utilization_pre_sp2
       END AS sql_cpu_utilization
	   , GETDATE() as collect_date
FROM ( select record.value ('(Record/@id)[1]', 'int')                                                   as record_id
             , dateadd (ms, -1 * ( @ts_now - [timestamp] ), getdate ())                                  as EventTime
             , 100 - record.value ('(Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int')   as system_cpu_utilization_post_sp2
             , record.value ('(Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int') as sql_cpu_utilization_post_sp2
             , 100 - record.value ('(Record/SchedluerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int')   as system_cpu_utilization_pre_sp2
             , record.value ('(Record/SchedluerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int') as sql_cpu_utilization_pre_sp2
    FROM ( SELECT timestamp
                    , convert (xml, record) as record
        FROM sys.dm_os_ring_buffers
        WHERE ring_buffer_type = 'RING_BUFFER_SCHEDULER_MONITOR'
            AND record LIKE '%<SystemHealth>%' ) as t ) as t
ORDER BY record_id DESC;
