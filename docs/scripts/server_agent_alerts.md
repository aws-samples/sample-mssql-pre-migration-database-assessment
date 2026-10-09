# server_agent_alerts.sql

### Description

Script to retrieve SQL Server Agent Alerts

### Permissions needed

- VIEW SERVER STATE

### Scope

- Server

### Tables queried

- dbo.sysalerts

#### Columns
- SQLInstance
- AlertName
- EventSource
- MessageID
- Enabled
- has_notification
- delay_between_responses
- occurrence_count
- last_occurrence_date
- last_occurrence_time
- collect_date


### AwsDatabaseAssessment Table Name

- raw.server_agent_alerts


### Sample Results

| SQLInstance  |  AlertName | EventSource  | MessageID  |  Enabled | has_notification | delay_between_responses | occurrence_count | last_occurrence_date | last_occurrence_time | collect_date |
|---|---|---|---|---|---|---|---|---|---|---|
AOAG-NODE-1| Peer-to-peer conflict detection alert|	MSSQLSERVER|22815|0|0|0|0|0|0|2022-12-13 16:15:39.823|
