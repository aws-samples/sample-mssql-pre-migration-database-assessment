#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

<#
    .SYNOPSIS
    Invoke-HardwareInfoReport.ps1

    .DESCRIPTION
    This script collects various information on Microsoft SQL Servers.
    It requires the SqlServer PowerShell Module and WMF5.1 to be installed.

    .PARAMETER ServerName
        The SQL Server Instance name. If the target is a named Instance , it must have host\instance name e.g. SERVER1\PROD

    .PARAMETER ScriptFolder
        The folder location tothe .SQL files to be executed

    .EXAMPLE
    # Manually add servers
    .\Invoke-HardwareInfoReport.ps1 -ServerName 'Server1' -ReportPath 'C:\Temp'

    .NOTES
        Author:     Marcos Freccia (mfreccia)
        Description: Script creation
        Date:       19/11/2021
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)][String]$serverName,
    [Parameter(Mandatory = $true)][String]$OutputFolder
)
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Management.IntegrationServices") | Out-Null;

function Get-SSISOnRDSNonSupportedFeature {

    param
    (
        [string] $ProjectName,
        [string] $ZipFileLocation,
        [string] $SQLInstance,
        [string] $OutputFolder
    )
    $ZipFile = Get-Item $ZipFileLocation

    foreach ($zip in $ZipFile) {

        $FolderName = -join ($($zip.DirectoryName), "\", $($zip.BaseName))

        if (!(Test-Path -Path $FolderName)) {
            New-Item -Path $FolderName -ItemType Directory | Out-Null
        }

        Expand-Archive -LiteralPath $zip.FullName -DestinationPath $FolderName -Force

        $DtsxFiles = Get-ChildItem -Path $FolderName -Filter "*.dtsx"

        foreach ($dtsx in $DtsxFiles) {
            [xml]$Data = Get-Content -Path $dtsx.FullName

            foreach ($dt in $Data) {

                foreach ($CreationName in $dt.DocumentElement.Executables.Executable) {

                    $SupportedValues = ("Microsoft.ExecuteSQLTask", "Microsoft.Pipeline", "STOCK:SEQUENCE", "Microsoft.ExecutePackageTask", "STOCK:FOREACHLOOP",
                    "Microsoft.ASExecuteDDLTask","Microsoft.DTSProcessingTask","Microsoft.BulkInsertTask","Microsoft.DbMaintenanceCheckIntegrityTask",
                    "Microsoft.DMQueryTask","Microsoft.DataProfilingTask","Microsoft.DbMaintenanceExecuteAgentJobTask","Microsoft.DbMaintenanceTSQLExecuteTask",
                    "Microsoft.DbMaintenanceNotifyOperatorTask","Microsoft.DbMaintenanceReindexTask","Microsoft.DbMaintenanceDefragmentIndexTask","Microsoft.DbMaintenanceShrinkTask",
                    "Microsoft.TransferDatabaseTask","Microsoft.TransferJobsTask","Microsoft.TransferLoginsTask","Microsoft.TransferSqlServerObjectsTask",
                    "Microsoft.DbMaintenanceUpdateStatisticsTask","STOCK:FOREACHLOOP","STOCK:FORLOOP","SSIS.Pipeline.3",'Microsoft.TransferObjectsTask',
                    "Microsoft.SqlServer.Dts.Tasks.ExecuteSQLTask.ExecuteSQLTask, Microsoft.SqlServer.SQLTask, Version=11.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91")
                    if ($CreationName.CreationName -notin $SupportedValues) {
                        Write-Output "$SQLInstance;$ProjectName;$($dtsx.Name);$($CreationName.CreationName)" | Out-File $OutputFolder\temp_ssisdb_componenttype.txt -Encoding utf8 -Append

                    }

                }
                   $NonSupportedValues = ('FLATFILE','ADO.NET:System.Data.SqlClient.SqlConnection, System.Data, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089',
                                           'FILE','EXCEL','HTTP')
                foreach ($ConnType in $dt.DocumentElement.ConnectionManagers.ConnectionManager) {
                            if($ConnType.CreationName -in $NonSupportedValues){
                                Write-Output "$SQLInstance;$ProjectName;$($dtsx.Name);$($ConnType.CreationName)" | Out-File $OutputFolder\temp_ssisdb_connectiontype.txt -Encoding utf8 -Append
                     }
                }
            }
        }
    }
    $ComponentTypeHeader = 'SQLInstance', 'ProjectName', 'PackageName', 'ComponentType'
    $ConnectionTypeHeader = 'SQLInstance', 'ProjectName', 'PackageName', 'ConnectionType'

    if(Test-Path $OutputFolder\temp_ssisdb_componenttype.txt){
    $DataX = Import-Csv $OutputFolder\temp_ssisdb_componenttype.txt -Delimiter ";" -Header $ComponentTypeHeader
    $DataX | Export-Csv $OutputFolder\ssis_packages_component_type_ssisdb.csv -Delimiter ";" -NoTypeInformation
    }
    if(Test-Path $OutputFolder\temp_ssisdb_connectiontype.txt){
    $DataY = Import-Csv $OutputFolder\temp_ssisdb_connectiontype.txt -Delimiter ";" -Header $ConnectionTypeHeader
    $DataY | Export-Csv $OutputFolder\ssis_packages_connection_type_ssisdb.csv -Delimiter ";" -NoTypeInformation
    }


}


Function Get-ProjectsTsql {
    param
    (
        [Microsoft.SqlServer.Management.IntegrationServices.CatalogFolder] $folder,
        [string] $serverName,
        [string] $OutputFolder
    )


    $connectionString = [String]::Format("Data Source={0};Initial Catalog=msdb;Integrated Security=SSPI;", $serverName)
    $connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
    $connection.Open()

    #Instance of ProjectInfo
    foreach ($proj in $folder.Projects) {
        $projName = $proj.Name
        $folderName = $folder.Name

        $zipOutSSISFolder = -join($OutputFolder,"\",$projName,".zip")
        $zipOut = $zipOutSSISFolder



        $query = "exec [SSISDB].[catalog].[get_project] @folder_name=N'$folderName',@project_name=N'$projName'"

        $command = New-Object System.Data.SqlClient.SqlCommand
        $command.CommandText = $query
        $command.Connection = $connection
        $projectBinary = $command.ExecuteScalar()
        if ($null -ne $projectBinary) {
            [System.IO.File]::WriteAllBytes($zipOut, $projectBinary)
        }
    }
    $connection.Close()
    if($projName){
    Write-Output "Starting the execution of Get-SSISOnRDSNonSupportedFeature -ProjectName $projName -ZipFileLocation $zipOut -SQLInstance $serverName -OutputFolder $OutputFolder"
    Get-SSISOnRDSNonSupportedFeature -ProjectName $projName -ZipFileLocation $zipOut -SQLInstance $serverName -OutputFolder $OutputFolder
    }
}

Function Get-CatalogFolder {
    param
    (
        [string] $serverName
    )

    $connectionString = [String]::Format("Data Source={0};Initial Catalog=msdb;Integrated Security=SSPI;", $serverName)

    $connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)

    $integrationServices = New-Object Microsoft.SqlServer.Management.IntegrationServices.IntegrationServices($connection)
    # The one, the only SSISDB catalog
    $catalog = $integrationServices.Catalogs["SSISDB"]

    $catalogFolders = $catalog.Folders

     return $catalogFolders
}

$SSISFolder = -join($OutputFolder,"\","SSISDB")

if (!(Test-Path -Path $SSISFolder)) {
    Write-Output "Creating folder [$SSISFolder]"
    New-Item -Path $SSISFolder -ItemType Directory | Out-Null
}
else {
    Write-Output "Removing contents of folder [$SSISFolder]"
    Remove-item -Path $SSISFolder -Recurse -Force
}


foreach ($folder in Get-CatalogFolder $serverName) {
    # Save out all the projects to their zip files
    Get-ProjectsTsql $folder $serverName $OutputFolder
}
