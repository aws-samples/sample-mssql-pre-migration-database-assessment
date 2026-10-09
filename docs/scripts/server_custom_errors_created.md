# server_custom_errors_created.sql

### Description

Script to return information about custom error messages created in the instance

### Permissions needed

- Requires membership in the public role

### Scope

- Server

### Tables queried

- dbo.sysmessages

#### Columns
- SQLInstance
- Message
- ErrorID
- LanguageID
- ErrorSeverity
- collect_date


### AwsDatabaseAssessment Table Name

- raw.server_custom_errors_created


### Sample Results

| SQLInstance  |  Message | ErrorID  | LanguageID  |  ErrorSeverity | collect_date |
|---|---|---|---|---|---|
|AOAG-NODE-1|Sample custom error message|50001|1033|10|2022-12-07 13:01:55.997|
