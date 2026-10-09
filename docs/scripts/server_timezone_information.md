# server_timezone_information.sql

### Description

This SQL Server script retrieves the timezone configuration of the server. It reads the timezone information from the Windows Registry and provides details about the server's timezone configuration. This information can be useful for understanding the server's timezone settings.


### Permissions needed

- Execute permission on xp_regread

### Scope

- Server

### Tables queried

- None

#### Columns

- SQLInstance
- TimezoneConfiguration
- collect_date


### AwsDatabaseAssessment Table Name

- raw.server_timezone_information


### Sample Results

| SQLInstance | TimezoneConfiguration | collect_date        |
|------------|------------------------|---------------------|
| Server1    | Pacific Standard Time  | 2023-11-07 10:30:00 |
