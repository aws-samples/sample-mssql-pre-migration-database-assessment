# feature_supportability

## Description

This table stores information about the supportability of features across different editions of SQL Server.


## Schema

- dbo

## Table Columns

| Column Name      | Data Type   | Description                                    | Constraints         | Example Values   |
|------------------|-------------|------------------------------------------------|---------------------|------------------|
| `Feature`        | NVARCHAR(255) | Name of the SQL Server feature                | NULL                | In-Memory OLTP   |
| `Enterprise`     | NVARCHAR(5)   | Supportability status in SQL Server Enterprise Edition | NULL          | Yes              |
| `Standard`       | NVARCHAR(5)   | Supportability status in SQL Server Standard Edition | NULL            | Yes              |
| `SkuFeatureCode` | NVARCHAR(50)  | SKU feature code                               | NULL                | E001             |
| `Description`    | NVARCHAR(MAX) | Description of the feature                     | NULL                | This feature enables ... |

## Indexes

- `ix_feature_supportability`: Clustered index on the `Feature` column for faster lookup of features.

## Script

- Created and populated as part of the AwsDatabaseAssessment.sql script execution
