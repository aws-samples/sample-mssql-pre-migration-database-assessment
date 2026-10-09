# server_agent_operators.sql

### Description

Script to get SQL Server Agent Operator information

### Permissions needed

- db_datareader on MSDB

### Scope

- Server

### Tables queried

- dbo.sysoperators

#### Columns
- SQLInstance
- name
- enabled
- email_address
- last_email_date
- last_email_time
- collect_date


### AwsDatabaseAssessment Table Name

- raw.server_agent_operators


### Sample Results

| SQLInstance  |  name | enabled  | email_address  |  last_email_date | last_email_time | collect_date |
|---|---|---|---|---|---|---|
AOAG-NODE-1| DBA |1	|dba@example.com|0|0|2022-12-13 16:35:57.333|
