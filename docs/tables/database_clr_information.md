# database_clr_information

## Description

This table contains information about Common Language Runtime (CLR) objects in databases on SQL Server instances.

## Schema

- raw

## Table Columns

| Column Name          | Data Type     | Description                               | Constraints         | Example Values           |
|----------------------|---------------|-------------------------------------------|----------------------|--------------------------|
| `SQLInstance`        | VARCHAR(50)   | SQL Server instance name                  | NULL                 | ServerA                  |
| `DatabaseName`       | VARCHAR(100)  | Name of the database                      | NULL                 | AdventureWorks2019       |
| `SchemaName`         | VARCHAR(50)   | Name of the schema                        | NULL                 | dbo                      |
| `ObjectName`         | NVARCHAR(100) | Name of the CLR object                    | NULL                 | MyClrObject              |
| `AssemblyName`       | NVARCHAR(100) | Name of the assembly                      | NULL                 | MyAssembly               |
| `AssemblyClass`      | NVARCHAR(1024)| Class name in the assembly                | NULL                 | MyClass                  |
| `AssemblyMethod`     | NVARCHAR(100) | Method name in the assembly               | NULL                 | MyMethod                 |
| `PermissionSetDesc`  | NVARCHAR(50)  | Description of permission set             | NULL                 | SAFE                     |
| `TypeDesc`           | NVARCHAR(50)  | Description of the CLR object type        | NULL                 | TABLE                    |
| `collect_date`       | DATETIME      | Date and time of data collection          | NULL                 | 2024-03-05 19:30:00      |

## Indexes

- `ix_database_clr_information_sql_instance`: Clustered index on the `SQLInstance` column for faster lookup of SQL Instances.

## Script

- [database_clr_information](../scripts/database_clr_information.md)
