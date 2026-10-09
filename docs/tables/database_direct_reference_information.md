# database_direct_reference_information

### Description

This table contains information about direct references between objects in different databases on SQL Server instances.

### Schema

- raw

### Table Columns

| Column Name                  | Data Type     | Description                               | Constraints         | Example Values           |
|------------------------------|---------------|-------------------------------------------|----------------------|--------------------------|
| `SQLInstance`                | VARCHAR(50)   | SQL Server instance name                  | NULL                 | ServerA                  |
| `referencing_database_name`  | VARCHAR(100)  | Name of the referencing database          | NULL                 | AdventureWorks2019       |
| `referencing_schema_name`    | VARCHAR(50)   | Name of the referencing schema            | NULL                 | dbo                      |
| `referencing_object_name`    | VARCHAR(128)  | Name of the referencing object            | NULL                 | MyReferencingObject      |
| `referencing_object_type`    | VARCHAR(60)   | Type of the referencing object            | NULL                 | TABLE                    |
| `referenced_database_location` | VARCHAR(10) | Location of the referenced database       | NULL                 | local                    |
| `referenced_server_name`     | VARCHAR(50)   | Name of the referenced server             | NULL                 | ServerB                  |
| `referenced_database_name`   | VARCHAR(128)  | Name of the referenced database           | NULL                 | AdventureWorks2020       |
| `referenced_schema_name`     | VARCHAR(128)  | Name of the referenced schema             | NULL                 | dbo                      |
| `referenced_object_name`     | VARCHAR(128)  | Name of the referenced object             | NULL                 | MyReferencedObject       |
| `collect_date`               | DATETIME      | Date and time of data collection          | NULL                 | 2024-03-06 10:45:00      |

### Indexes

- `ix_database_direct_reference_information_sql_instance`: Clustered index on the `SQLInstance` column and `referencing_database_name` column for faster lookup of SQL Instances.

### Script

- [database_direct_reference_information](../scripts/database_direct_reference_information.md)
