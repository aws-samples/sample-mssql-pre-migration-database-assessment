# database_replication_publisher_information.sql

### Description

Script to collect replication information on the publisher database

### Permissions needed

- db_datareader on the publisher database

### Scope

- Database

### Tables queried

- dbo.syspublications
- dbo.sysarticles
- dbo.syssubscriptions
- dbo.sysservers

#### Columns
- SQLInstance
- PublisherDatabase
- PublicationName
- SchemaName
- TableName
- SubscriberServerName
- collect_date


### AwsDatabaseAssessment Table Name

- raw.database_replication_publisher_information


### Sample Results

| SQLInstance  |  PublisherDatabase | PublicationName  | SchemaName  |  TableName | SubscriberServerName | collect_date|
|---|---|---|---|---|---|---|---|
|AOAG-NODE-1|BikeStores|BikeStoresRepl|production|brands|AOAG-NODE-2|2022-12-12 14:49:49.947|
|AOAG-NODE-1|BikeStores|BikeStoresRepl|production|categories|AOAG-NODE-2|2022-12-12 14:49:49.947|
