# server_trigger_information.sql

### Description

This SQL Server script retrieves information about server-level triggers and their associated events on the SQL Server instance. It provides details about trigger names, parent class descriptions, trigger type descriptions, create dates, modify dates, whether they are system objects, whether they are disabled, event type descriptions, and event group type descriptions. The results help you understand and manage server-level triggers and their associated events.


### Permissions needed

- VIEW SERVER STATE

### Scope

- Server

### Tables queried

- sys.server_triggers
- sys.server_trigger_events

#### Columns

- SQLInstance
- name
- parent_class_desc
- type_desc
- create_date
- modify_date
- is_ms_shipped
- is_disabled
- event_type_desc
- event_group_type_desc
- collect_date


### AwsDatabaseAssessment Table Name

- raw.server_trigger_information


### Sample Results

| SQLInstance | name                   | parent_class_desc | type_desc    | create_date         | modify_date         | is_ms_shipped | is_disabled | event_type_desc | event_group_type_desc | collect_date         |
|------------|------------------------|-------------------|-------------|---------------------|---------------------|---------------|------------|----------------|-----------------------|---------------------|
| Server1    | MyServerTrigger1       | SERVER            | SQL_TRIGGER   | 2023-01-15 12:30:00 | 2023-11-03 09:45:00 | 0             | 0          | LOGON          | SERVER                | 2023-11-07 10:30:00|
