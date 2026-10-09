# mpa.ConfirmDowngradeToStandard

## Description

This stored procedure calculates the probability of a successful downgrade to the standard edition of SQL Server for a given SQL instance and database. It analyzes the features used in the specified database and assesses the downgrade possibility based on the SQL Server version and edition. The procedure then assigns a downgrade success probability to each feature and calculates an overall percentage of success.


## How the calculation is done

The procedure assigns three scores to determine the downgrade success probability for each feature:

- `@ScoreForNo`: Score assigned when the downgrade is not possible (`'NO'` in the `DowngradePossible` column).
- `@ScoreForYes`: Score assigned when the downgrade is possible (`'YES'` in the `DowngradePossible` column).
- `@ScoreForOther`: Score assigned for other possibilities (`'YES 2'` or `'YES 1'` in the `DowngradePossible` column).

The percentage of success is calculated as follows:

- The scores are summed up for all features.
- The sum is divided by the total number of features.
- The result is multiplied by 100 to get the percentage of success.

## Permissions needed

- `db_owner`

## Tables queried

- raw.database_downgrade_to_standard
- raw.server_general_information
- dbo.feature_supportability


## Parameters

| Parameter Name     | Data Type      | Description                                                              |
|--------------------|----------------|--------------------------------------------------------------------------|
| `@SQLInstance`    | VARCHAR(50)    | Input parameter representing the SQL instance for which the downgrade probability is calculated. |
| `@DatabaseName`    | VARCHAR(100)    | Input parameter representing the name of the database for which the downgrade probability is calculated. |


## Usage

To execute the `mpa.ConfirmDowngradeToStandard` stored procedure, follow these steps:

1. Open a SQL query window in your database management tool.
2. Use the following SQL command to call the procedure:

```sql
EXEC mpa.ConfirmDowngradeToStandard @SQLInstance = 'EC2AMAZ-913FB8D', @DatabaseName = 'AdventureWorks2016_EXT';
```

## Sample Results

| SQLInstance       | SQLServerMajorVersion | ProductLevel | DatabaseName            | PercentageOfSuccess |
|-------------------|-----------------------|--------------|-------------------------|---------------------|
| EC2AMAZ-913FB8D   | SQL Server 2019       | RTM          | AdventureWorks2016_EXT  | 75.00               |
| EC2AMAZ-913FB8D   | SQL Server 2017       | RTM          | WideWorldImporters      | 100.00              |
| EC2AMAZ-913FB8D   | SQL Server 2016       | RTM          | AdventureWorks2016_EXT  | 50.00               |
