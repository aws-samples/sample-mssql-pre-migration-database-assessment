# dbo.vw_clr_usage

## Description

This view provides information on Common Language Runtime (CLR) usage within SQL Server databases. It retrieves data from the `vw_database_general_information` and `raw.database_clr_information` tables, displaying details such as SQL instance, database name, CLR object name, CLR permission set description, and CLR type description. It is primarily used for generating the ADM Questionnaire Spreadsheet to confirm CLR usage.

## Schemas Touched

- dbo
- raw

## Permissions

This view requires appropriate permissions to access the following objects:

- [`dbo.vw_database_general_information`](dbo.vw_database_general_information.md)
- [`raw.database_clr_information`](../tables/database_clr_information.md)

## Sample Results

Below is an example of the output you can expect from this view:

| SQLInstance  | DatabaseName        | ObjectName | PermissionSetDesc | TypeDesc    |
|--------------|---------------------|------------|-------------------|-------------|
| SQLInstance1 | AdventureWorks2016  | MyCLRProc  | SAFE_ACCESS       | STORED_PROC |
| SQLInstance2 | AdventureWorks2016  | CLR_UDF    | UNSAFE            | FUNCTION    |
