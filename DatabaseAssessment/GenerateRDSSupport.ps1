#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

<#
    .SYNOPSIS
    GenerateRDSSupport.ps1

    .DESCRIPTION
    Generates an Excel report showing RDS support status for all SQL Server instances
    found in the assessment database. The report highlights features that are supported
    or not supported on Amazon RDS for SQL Server.

    .PARAMETER SqlInstance
        The SQL Server instance name where the AwsDatabaseAssessment database resides.
        Defaults to the local computer name.

    .PARAMETER DatabaseName
        The name of the assessment database. Defaults to 'AwsDatabaseAssessment'.

    .PARAMETER OutputFolder
        The folder where the output Excel file will be created.
        Defaults to the DB_ASSESSMENT_HOME environment variable.

    .EXAMPLE
    .\GenerateRDSSupport.ps1

    .EXAMPLE
    .\GenerateRDSSupport.ps1 -SqlInstance "SERVER01"

    .EXAMPLE
    .\GenerateRDSSupport.ps1 -SqlInstance "SERVER01" -DatabaseName "MyAssessmentDB" -OutputFolder "C:\Reports"

    .NOTES
        Author: AWS Database Migration Team
#>

param (
    [Parameter(Mandatory = $false)]
    [string]$SqlInstance = $Env:COMPUTERNAME,

    [Parameter(Mandatory = $false)]
    [string]$DatabaseName = 'AwsDatabaseAssessment',

    [Parameter(Mandatory = $false)]
    [string]$OutputFolder = $Env:DB_ASSESSMENT_HOME
)

#############
# Functions
#############
function Test-CommandParameter {
    param (
        [string]$CommandName,
        [string]$ParameterName
    )

    try {
        $command = Get-Command $CommandName -ErrorAction SilentlyContinue
        if (-not $command) { return $false }
        if (-not $command.Parameters) { return $false }
        return ($command.Parameters.Keys -contains $ParameterName)
    }
    catch {
        return $false
    }
}

# Validate OutputFolder
if ([string]::IsNullOrWhiteSpace($OutputFolder)) {
    if (![System.Environment]::GetEnvironmentVariables()['DB_ASSESSMENT_HOME']){
        Throw "OutputFolder parameter not provided and DB_ASSESSMENT_HOME environment variable doesn't exist. Set one of them before proceeding."
    }
    $OutputFolder = $Env:DB_ASSESSMENT_HOME
}

# Check and install required modules
$ImportExcelModuleExists = Get-Module ImportExcel -ListAvailable
if (!$ImportExcelModuleExists) {
    Write-Output "ImportExcel module not found. Installing..."
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Install-Module -Name ImportExcel -AllowClobber -Scope CurrentUser -Force
    Import-Module ImportExcel
}

Write-Output "Using output folder: $OutputFolder"

$date = Get-Date -format "yyyyMMdd"
$ExcelFileName = -join("RDSSupport_V1_",$date,".xlsx")

$OutputFile = Join-Path -Path $OutputFolder -ChildPath $ExcelFileName
Write-Output "Output file is: $OutputFile"

# Prepare the base parameters
$params = @{
    ServerInstance = $SqlInstance
    Database = $DatabaseName
    Query = "SELECT SQLInstance from raw.server_general_information;"
}
# Check if the TrustServerCertificate parameter exists
if (Test-CommandParameter -CommandName "Invoke-Sqlcmd" -ParameterName "TrustServerCertificate") {
    $params.TrustServerCertificate = $true
}
# Enforce TLS encryption if supported (SqlServer module v22+)
if (Test-CommandParameter -CommandName "Invoke-Sqlcmd" -ParameterName "Encrypt") {
    $params.Encrypt = "Mandatory"
}
# Execute the command
$AppSQLInstances = Invoke-Sqlcmd @params

foreach ($AppSQLInstance in $AppSQLInstances){
$AppSQLInstance = $AppSQLInstance.SQLInstance

##### Generate RDS Support Tab ######
Write-Output "Generating RDS Support Tab for $AppSQLInstance"
$params = @{
    ServerInstance = $SqlInstance
    Database = $DatabaseName
    Query = "EXEC mpa.ConfirmRDSSupport @SQLInstance = '`$(InstanceName)';"
    Variable = "InstanceName=$AppSQLInstance"
}
# Check if the TrustServerCertificate parameter exists
if (Test-CommandParameter -CommandName "Invoke-Sqlcmd" -ParameterName "TrustServerCertificate") {
    $params.TrustServerCertificate = $true
}
# Enforce TLS encryption if supported (SqlServer module v22+)
if (Test-CommandParameter -CommandName "Invoke-Sqlcmd" -ParameterName "Encrypt") {
    $params.Encrypt = "Mandatory"
}
# Execute the command
$RDSSupportInformation = Invoke-Sqlcmd @params


$RDSSupportInformation = $RDSSupportInformation | ConvertTo-Csv -Delimiter ";" -NoTypeInformation

$excel = $RDSSupportInformation | ConvertFrom-Csv -Delimiter ";" | Export-Excel -Path $OutputFile -AutoSize -BoldTopRow -WorksheetName 'RDS Support' -AutoFilter -FreezeTopRow -PassThru -Append

$rds = $excel.Workbook.Worksheets["RDS Support"]

Add-ConditionalFormatting -WorkSheet $rds -address $rds.Dimension.Address -RuleType ContainsText -ConditionValue "False" -BackgroundColor LightGreen
Add-ConditionalFormatting -WorkSheet $rds -address $rds.Dimension.Address -RuleType ContainsText -ConditionValue "True" -BackgroundColor Yellow



Close-ExcelPackage $excel

}
