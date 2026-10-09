# ssis_packages_connection_type_msdb.sql

## Description

This SQL Server script is designed to check for any file system tasks being utilized within SSIS Packages located in the MSDB database. It retrieves information about the packages, including folder names, package names, connection types, and task types. This script is useful for monitoring and analyzing file system tasks within SSIS packages.

## Permissions needed

- `db_datareader` on `msdb` database

## Scope

- Database

## Tables queried

- `sysssispackages`
- `sysssispackagefolders`

## Columns

- `SQLInstance`
- `FolderName`
- `PackageName`
- `ConnectionType`
- `TaskType`
- `collect_date`

## Sample Results

| SQLInstance | FolderName | PackageName | ConnectionType | TaskType | collect_date          |
|-------------|------------|-------------|----------------|----------|-----------------------|
| ServerName  | Folder1    | Package1    | FLATFILE       | N/A      | 2024-03-07 10:30:00  |
| ServerName  | Folder1    | Package1    | ADO.NET        | N/A      | 2024-03-07 10:30:00  |
| ServerName  | Folder2    | Package2    | N/A            | TaskType | 2024-03-07 10:31:00  |
