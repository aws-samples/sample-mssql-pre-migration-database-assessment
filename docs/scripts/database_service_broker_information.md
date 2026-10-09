# database_service_broker_information.sql

### Description

Script to retrieve service broker information


### Permissions needed

- public on the user database

### Scope

- Database

### Tables queried

- sys.service_queues

#### Columns
- SQLInstance
- name
- type
- create_date
- modify_date
- collect_date


### AwsDatabaseAssessment Table Name

- raw.database_service_broker_information


### Sample Results

| SQLInstance  |  name | type  | create_date  |  modify_date | collect_date |
|---|---|---|---|---|---|
|AOAG-NODE-1|OrderQueue|SQ|2022-12-12 15:02:22.400|2022-12-12 15:02:22.400|2022-12-07 13:01:55.997|
