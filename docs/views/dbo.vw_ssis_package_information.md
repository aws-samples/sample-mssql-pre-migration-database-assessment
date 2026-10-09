# dbo.vw_ssis_package_information

## Description

This view provides information about SQL Server Integration Services (SSIS) packages deployed in both MSDB and SSISDB catalog. It retrieves data from the tables `raw.database_msdb_ssis_packages` and `raw.database_ssisdb_ssis_packages`. Details such as SQL instance, root folder, full path, package name, description, and non-supported components are included in the output. The view also identifies the package deployment type, whether it's deployed in MSDB or SSISDB.

## Schemas Touched

- dbo
- raw

## Permissions

This view requires appropriate permissions to access the following objects:

- [`raw.database_msdb_ssis_packages`](../tables/database_msdb_ssis_packages.md)
- [`raw.database_ssisdb_ssis_packages`](../tables/database_ssisdb_ssis_packages.md)
- [`raw.ssis_packages_connection_type_msdb`](../tables/ssis_packages_connection_type_msdb.md)
- [`raw.ssis_packages_component_type_ssisdb`](../tables/ssis_packages_component_type_ssisdb.md)
- [`raw.ssis_packages_connection_type_ssisdb`](../tables/ssis_packages_connection_type_ssisdb.md)

## Sample Results

Below is an example of the output you can expect from this view:

| SQLInstance  | RootFolder       | FullPath                   | PackageName   | Description   | RDSNonSupportedComponents | Package Deployment Type |
|--------------|------------------|----------------------------|---------------|---------------|---------------------------|-------------------------|
| SQLInstance1 | RootFolder1      | RootFolder1/Project1       | Package1.dtsx | Description1  | [{"ConnectionType":"..."}]| Deployed in MSDB        |
| SQLInstance2 | Folder2          | Folder2/Project2           | Package2.dtsx | Description2  | [{"ConnectionType":"..."}]| Deployed in SSISDB      |
