# server_deprecated_features

### Description

This table contains information about deprecated features on SQL Server instances.

### Schema

- raw

### Table Columns

| Column Name          | Data Type     | Description                           | Constraints    | Example Values           |
|----------------------|---------------|---------------------------------------|----------------|--------------------------|
| `SQLInstance`        | VARCHAR(50)   | SQL Server instance name              | NULL           | ServerA                  |
| `DeprecatedFeature`  | NVARCHAR(128) | Name of the deprecated feature        | NULL           | LegacyCompatibilityMode |
| `UsageCount`         | INT           | Number of times the feature was used  | NULL           | 10                       |
| `collect_date`       | DATETIME      | Date and time of data collection      | NULL           | 2024-03-06 20:00:00      |

### Indexes

- `ix_server_deprecated_features_sql_instance`: Clustered index on the `SQLInstance` column for faster lookup of SQL Instances.


### Script

- [server_deprecated_features](../scripts/server_deprecated_features.md)
