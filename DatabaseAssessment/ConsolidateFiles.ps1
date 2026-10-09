#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

# Script for consolidating data

if (![System.Environment]::GetEnvironmentVariables()['DB_ASSESSMENT_HOME']){
    Throw "DB_ASSESSMENT_HOME doesn't exist. Create it, before proceeding"
}

Write-Output $Env:DB_ASSESSMENT_HOME

$OutputFolderLocation = Join-Path -Path $Env:DB_ASSESSMENT_HOME -ChildPath mssql-pre-database-assessment

# Update if necessary only
$ConsolidatedFolderLocation = Join-Path -Path $Env:DB_ASSESSMENT_HOME -ChildPath ConsolidatedFiles
$Files = Get-ChildItem -Path $OutputFolderLocation -Filter '*.csv' -Recurse

if(!(Test-Path $ConsolidatedFolderLocation)){
New-Item -ItemType Directory -Path $ConsolidatedFolderLocation | Out-Null
}
else {
Get-ChildItem -Path $ConsolidatedFolderLocation -Filter '*.csv' | Remove-Item -Force
}

Write-Output "Starting the consolidation of files"
foreach($fl in $Files){
$FileToImport = $fl.FullName
try{

Write-Verbose "Importing [$FileToImport] to $ConsolidatedFolderLocation"
Import-Csv -Delimiter ";" -Path $FileToImport | Export-Csv (Join-Path $ConsolidatedFolderLocation -ChildPath $fl.Name) -Delimiter ";" -NoTypeInformation -Append -Force

}
catch{
Write-Output "Failed to import: $FileToImport"
Write-Error $_
    }
Write-Output "Consolidation has been completed"
}
