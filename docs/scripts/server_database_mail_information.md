# server_database_mail_information.sql

### Description

Script to retrieve database mail configuration


### Permissions needed

- db_datareader on msdb

### Scope

- Server

### Tables queried

- dbo.sysmail_profile
- dbo.sysmail_profileaccount
- dbo.sysmail_account
- dbo.sysmail_server

#### Columns
- SQLInstance
- ProfileName
- ProfileDescription
- LastModificationDate
- LastModificationUser
- AccountID
- AccountName
- AccountDescription
- EmailAddress
- DisplayName
- ReplyToAddress
- ServerType
- ServerName
- Port
- Username
- SSLEnabled
- collect_date


### AwsDatabaseAssessment Table Name

- raw.server_database_mail_information


### Sample Results

| SQLInstance  |  ProfileName | ProfileDescription  | LastModificationDate  |  LastModificationUser | AccountID | AccountName | AccountDescription | EmailAddress | DisplayName | ReplyToAddress | ServerType | ServerName | Port | Username | SSLEnabled | collect_date |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
|AOAG-NODE-1|DBA Profile|DBA Team|2023-03-13 10:43:18.183|CORP\Admin|1|dba||dba-alerts@example.com|DBA Alerts||SMTP|smtp.example.com|25|NULL|1|2022-12-07 13:01:55.997|
