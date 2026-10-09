# database_ssrs_subscription_information.sql

### Description

Script to collect Reporting Services Subscription information

### Permissions needed

- db_datareader on the report server database

### Scope

- Database

### Tables queried

- dbo.Catalog
- dbo.Users
- dbo.Subscriptions
- dbo.ReportSchedule
- dbo.Schedule

#### Columns
- SQLInstance
- SubscriptionOwner
- ModifiedDate
- Description
- EventType
- DeliveryExtension
- LastStatus
- LastRunTime
- NextRunTime
- ScheduleName
- ReportPath
- ReportDescription
- Parameters
- collect_date

### AwsDatabaseAssessment Table Name

- raw.database_ssrs_subscription_information


### Sample Results

|SQLInstance| SubscriptionOwner | ModifiedDate         | Description            | EventType   | DeliveryExtension | LastStatus    | LastRunTime          | NextRunTime          | ScheduleName   | ReportPath                          | ReportDescription      | Parameters   | collect_date|
|---------|-------------------|-----------------------|------------------------|-------------|-------------------|---------------|----------------------|----------------------|----------------|------------------------------------|------------------------|--------------|---|
|EC2AMAZ-2I49TPN| EC2AMAZ-2I49TPN\Administrator             | 2023-09-20 12:30:00   | Monthly Sales Report   | TimedSubscription       | Report Server FileShare             | The file "Fees.csv" has been saved to the "\\EC2AMAZ-2I49TPN\Extracts" file share.     | 2023-09-15 08:00:00  | 2023-10-15 08:00:00  | MonthlyReport |/Fees    | Sales data for August | `<ParameterValues />`|
|EC2AMAZ-2I49TPN| EC2AMAZ-2I49TPN\Administrator             | 2023-09-20 11:45:00   | Weekly Marketing Report | TimedSubscription | Report Server FileShare               | The file "Fees_2.docx" has been saved to the "\\EC2AMAZ-2I49TPN\Extracts" file share. | 2023-09-19 09:15:00  | 2023-09-26 09:15:00  | WeeklyReport  | /Fees | Marketing data          | `<ParameterValues />` | 2023-09-20 15:04:26.170|
