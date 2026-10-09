# server_event_notification_information.sql

### Description

Script to list event notification on server level

### Permissions needed

- The visibility of the metadata in catalog views is limited to securables that a user either owns or on which the user has been granted some permission

### Scope

- Server

### Tables queried

- sys.server_event_notifications

#### Columns
- SQLInstance
- name
- object_id
- parent_class_desc
- create_date
- service_name
- collect_date


### AwsDatabaseAssessment Table Name

- raw.server_event_notifications


### Sample Results

| SQLInstance  |  name | object_id  | parent_class_desc  |  create_date | service_name | collect_date |
|---|---|---|---|---|---|---|
|AOAG-NODE-1|log_ddl1|599673184|SERVER|2023-03-13 11:00:17.023|NotifyService|2023-03-13 11:01:52.863|
