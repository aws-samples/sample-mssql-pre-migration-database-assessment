#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

<#
    .SYNOPSIS
    GenerateAppQuestionnaire.ps1

    .DESCRIPTION
    Generates an Excel-based assessment questionnaire for a specific application and environment.
    The output includes tabs for ADM questionnaire, general information, SSIS packages, SSRS reports,
    SQL Agent jobs, linked servers, database mail, sp_configure, database users, CLR objects,
    credentials, RDS support, and database dependencies.

    .PARAMETER SqlInstance
        The SQL Server instance name where the AwsDatabaseAssessment database resides. 
        Defaults to the local computer name.

    .PARAMETER DatabaseName
        The name of the assessment database. Defaults to 'AwsDatabaseAssessment'.

    .PARAMETER AppName
        The application name to generate the questionnaire for. Required.

    .PARAMETER Environment
        The environment name (e.g., 'Development', 'Quality Assurance', 'Production', 'Training'). 
        Required.

    .PARAMETER OutputFolder
        The base folder where the output Excel file will be created.
        Defaults to the DB_ASSESSMENT_HOME environment variable.

    .EXAMPLE
    .\GenerateAppQuestionnaire.ps1 -AppName "MyApp" -Environment "Production"

    .EXAMPLE
    .\GenerateAppQuestionnaire.ps1 -SqlInstance "SERVER01" -AppName "MyApp" -Environment "Development"

    .EXAMPLE
    .\GenerateAppQuestionnaire.ps1 -SqlInstance "SERVER01" -DatabaseName "MyAssessmentDB" -AppName "MyApp" -Environment "Production" -OutputFolder "C:\Reports"

    .NOTES
        Author: AWS Database Migration Team
#>

param (
    [Parameter(Mandatory = $false)]
    [string]$SqlInstance = $Env:COMPUTERNAME,

    [Parameter(Mandatory = $false)]
    [string]$DatabaseName = 'AwsDatabaseAssessment',

    [Parameter(Mandatory = $true)]
    [string]$AppName,

    [Parameter(Mandatory = $true)]
    [string]$Environment,

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

Write-Output "Working on [$AppName]"

# Check and install required modules
$ImportExcelModuleExists = Get-Module ImportExcel -ListAvailable
if (!$ImportExcelModuleExists) {
    Write-Output "ImportExcel module not found. Installing..."
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Install-Module -Name ImportExcel -AllowClobber -Scope CurrentUser -Force
    Import-Module ImportExcel
}

# Validate OutputFolder
if ([string]::IsNullOrWhiteSpace($OutputFolder)) {
    if (![System.Environment]::GetEnvironmentVariables()['DB_ASSESSMENT_HOME']){
        Throw "OutputFolder parameter not provided and DB_ASSESSMENT_HOME environment variable doesn't exist. Set one of them before proceeding."
    }
    $OutputFolder = $Env:DB_ASSESSMENT_HOME
}
# Prepare the base parameters
$params = @{
    ServerInstance = $SqlInstance
    Database = "master"
    Query = "SELECT COUNT(*) FROM sys.databases where name = 'AwsDatabaseAssessment';"
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
$AwsDatabaseAssessmentExists = Invoke-Sqlcmd @params
if (! $AwsDatabaseAssessmentExists){
    Throw "AwsDatabaseAssessment doesn't exist. Create it, before proceeding"
}
# Prepare the base parameters
$params = @{
    ServerInstance = $SqlInstance
    Database = $DatabaseName
    Query = "select DISTINCT master_app.ApplicationId, ApplicationName,Environment, SQLInstance from mpa.master_applications as master_app join mpa.master_databases as master_db on master_db.ApplicationId = master_app.ApplicationId where master_app.ApplicationName = '`$(AppNameParam)' AND Environment = '`$(EnvironmentParam)'"
    Variable = @("AppNameParam=$AppName", "EnvironmentParam=$Environment")
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
$AppServerInformation = Invoke-Sqlcmd @params

if ($AppServerInformation){



if($AppServerInformation.Count -gt 1){

$ApplicationName = $AppServerInformation.ApplicationName[0]
$AppEnvironment = $AppServerInformation.Environment[0]
$ApplicationId = $AppServerInformation.ApplicationId[0]
$date = Get-Date -format "yyyyMMdd"

}else{
$ApplicationName = $AppServerInformation.ApplicationName
$AppEnvironment = $AppServerInformation.Environment
$ApplicationId = $AppServerInformation.ApplicationId
$date = Get-Date -format "yyyyMMdd"

}
switch ($environment)
{
    "Development" { $FileNameAppEnvironment = 'DEV'; break }
    "Quality Assurance" { $FileNameAppEnvironment = 'QA'; break }
    "Production" { $FileNameAppEnvironment = 'PRD'; break }
    "Training" { $FileNameAppEnvironment = 'TR'; break }
}


# Generate the Excel File name based on some inputs
$ExcelFolderFileAppName = $ApplicationName.Replace(" ","")
$ExcelFolderFileAppName = $ExcelFolderFileAppName.Replace("\","$")


$ExcelFileName = -join("MSSQL_Assessment_Checklist_V1_",$ExcelFolderFileAppName,"_",$FileNameAppEnvironment,"_",$date,".xlsx")

$FolderName = -join($FileNameAppEnvironment," - ",$ApplicationId, " - " ,$ExcelFolderFileAppName)

$OutputFolder = Join-Path -Path $OutputFolder -ChildPath $FolderName

If(!(Test-Path -Path $OutputFolder)){
New-Item -Path $OutputFolder -ItemType Directory | Out-Null
}
else{

Remove-Item -Path $OutputFolder -Recurse -Force

}


$OutputFile = Join-Path -Path $OutputFolder -ChildPath $ExcelFileName
Write-Output "Output file is: $OutputFile"

Write-Output "Generating ADM Questionnaire"
# Prepare the base parameters
$params = @{
    ServerInstance = $SqlInstance
    Database = $DatabaseName
    Query = "SELECT Question, Answer, Comments FROM dbo.question_table where Environment = '`$(EnvironmentParam)' and enabled = 1 order by id"
    Variable = "EnvironmentParam=$Environment"
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
$ADMQuestions = Invoke-Sqlcmd @params

$ADMQuestions = $ADMQuestions | ConvertTo-Csv -Delimiter ";" -NoTypeInformation
$excel = $ADMQuestions | ConvertFrom-Csv -Delimiter ";" | Export-Excel -Path $OutputFile  -AutoSize -BoldTopRow -WorksheetName 'ADM Questionnaire' -AutoFilter -FreezeTopRow -PassThru

$ws = $excel.Workbook.Worksheets["ADM Questionnaire"]
$dimension = $ws.Dimension
$address=$dimension.address
Set-Format -WorkSheet $ws -Range $address -WrapText
Close-ExcelPackage -ExcelPackage $excel


Write-Output "Generating General Information Tab"
# Prepare the base parameters
$params = @{
    ServerInstance = $SqlInstance
    Database = $DatabaseName
    Query = "EXEC mpa.GeneralInformation @ApplicationName = '`$(AppNameParam)', @Environment = '`$(EnvironmentParam)'"
    Variable = @("AppNameParam=$ApplicationName", "EnvironmentParam=$AppEnvironment")
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
$GeneralInformation = Invoke-Sqlcmd @params
$GeneralInformation = $GeneralInformation | ConvertTo-Csv -Delimiter ";" -NoTypeInformation
$excelGeneralInformation = $GeneralInformation | ConvertFrom-Csv -Delimiter ";" | Export-Excel -Path $OutputFile -AutoSize -BoldTopRow -WorksheetName 'General Information' -AutoFilter -FreezeTopRow -PassThru

$ValidationParams = @{
    Worksheet        = $excelGeneralInformation.'General Information'
    ShowErrorMessage = $true
    ErrorStyle       = 'stop'
    ErrorTitle       = 'Invalid Data'
}
$MoreValidationParams = @{
    Range          = 'R2:R1001'
    ValidationType = 'List'
    ValueSet       = @('YES','NO','Yes','No')
    ErrorBody      = "You must select an item from the list."
}
Add-ExcelDataValidationRule @ValidationParams @MoreValidationParams

$MoreValidationParams = @{
    Range          = 'S2:S1001'
    ValidationType = 'List'
    ValueSet       = @('YES','NO','Yes','No')
    ErrorBody      = "You must select an item from the list."
}
Add-ExcelDataValidationRule @ValidationParams @MoreValidationParams


$MoreValidationParams = @{
    Range          = 'U2:U1001'
    ValidationType = 'List'
    ValueSet       = @('RDS','EC2')
    ErrorBody      = "You must select an item from the list."
}
Add-ExcelDataValidationRule @ValidationParams @MoreValidationParams

$MoreValidationParams = @{
    Range          = 'V2:V1001'
    ValidationType = 'List'
    ValueSet       = @('Backup/Restore','DMS/Replication','MGN')
    ErrorBody      = "You must select an item from the list."
}
Add-ExcelDataValidationRule @ValidationParams @MoreValidationParams


$MoreValidationParams = @{
    Range          = 'W2:W1001'
    ValidationType = 'List'
    ValueSet       = @('YES','NO','Yes','No')
    ErrorBody      = "You must select an item from the list."
}
Add-ExcelDataValidationRule @ValidationParams @MoreValidationParams

$MoreValidationParams = @{
    Range          = 'X2:X1001'
    ValidationType = 'List'
    ValueSet       = @('YES','NO','Yes','No')
    ErrorBody      = "You must select an item from the list."
}
Add-ExcelDataValidationRule @ValidationParams @MoreValidationParams

Close-ExcelPackage $excelGeneralInformation



foreach($App in $AppServerInformation){

$AppSQLInstance = $App.SQLInstance

##### Generate SSIS Packages Tab ######

Write-Output "Generating Confirm SSIS Package Tab for $AppSQLInstance"
# Prepare the base parameters
$params = @{
    ServerInstance = $SqlInstance
    Database = $DatabaseName
    Query = "EXEC mpa.ConfirmSSISPackages @SQLInstance = '`$(InstanceParam)'"
    Variable = "InstanceParam=$AppSQLInstance"
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
$ConfirmSSISPackages = Invoke-Sqlcmd @params

$ConfirmSSISPackages | Export-Csv -Delimiter ";" -Path (Join-Path -Path $OutputFolder -ChildPath temp_ssis_packages.csv) -NoTypeInformation

Import-Csv -Path (Join-Path -Path $OutputFolder -ChildPath temp_ssis_packages.csv) -Delimiter ';' | Export-Excel -Path $OutputFile -AutoSize -BoldTopRow -WorksheetName 'Confirm SSIS Packages' -AutoFilter -FreezeTopRow


##### Generate SSRS Reports Tab ######

Write-Output "Generating Confirm SSRS Reports Tab for $AppSQLInstance"
# Prepare the base parameters
$params = @{
    ServerInstance = $SqlInstance
    Database = $DatabaseName
    Query = "EXEC mpa.ConfirmSSRSReports @SQLInstance = '`$(InstanceParam)'"
    Variable = "InstanceParam=$AppSQLInstance"
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
$ConfirmSSRS = Invoke-Sqlcmd @params

if($ConfirmSSRS){
$ConfirmSSRS | Export-Csv -Delimiter ";" -Path (Join-Path -Path $OutputFolder -ChildPath temp_ssrs_reports.csv) -NoTypeInformation

Import-Csv -Path (Join-Path -Path $OutputFolder -ChildPath temp_ssrs_reports.csv) -Delimiter ';' | Export-Excel -Path $OutputFile -AutoSize -BoldTopRow -WorksheetName 'Confirm SSRS Reports' -AutoFilter -FreezeTopRow
}


##### Generate SQL Server Agent Jobs Tab ######

Write-Output "Generating Confirm Agent Job Tab for $AppSQLInstance"
# Prepare the base parameters
$params = @{
    ServerInstance = $SqlInstance
    Database = $DatabaseName
    Query = "EXEC mpa.ConfirmAgentJobs @ApplicationName = '`$(AppNameParam)', @Environment = '`$(EnvironmentParam)'"
    Variable = @("AppNameParam=$ApplicationName", "EnvironmentParam=$AppEnvironment")
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
$ConfirmSQLAgentJobs = Invoke-Sqlcmd @params

$ConfirmSQLAgentJobs | Export-Csv -Delimiter ";" -Path (Join-Path -Path $OutputFolder -ChildPath temp_sql_agent_jobs.csv) -NoTypeInformation

Import-Csv -Path (Join-Path -Path $OutputFolder -ChildPath temp_sql_agent_jobs.csv) -Delimiter ';' | Export-Excel -Path $OutputFile -AutoSize -BoldTopRow -WorksheetName 'Confirm SQL Server Agent Jobs' -AutoFilter -FreezeTopRow


##### Generate Linked Servers Tab ######

Write-Output "Generating Confirm Linked Server Tab for $AppSQLInstance"
# Prepare the base parameters
$params = @{
    ServerInstance = $SqlInstance
    Database = $DatabaseName
    Query = "EXEC mpa.ConfirmLinkedServers @SQLInstance = '`$(InstanceParam)';"
    Variable = "InstanceParam=$AppSQLInstance"
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
$ConfirmLinkedServers = Invoke-Sqlcmd @params
if($ConfirmLinkedServers){

$ConfirmLinkedServersInformation = $ConfirmLinkedServers | ConvertTo-Csv -Delimiter ";" -NoTypeInformation
$excelLinkedServers = $ConfirmLinkedServersInformation | ConvertFrom-Csv -Delimiter ";" | Export-Excel -Path $OutputFile -AutoSize -BoldTopRow -WorksheetName 'Confirm Linked Servers' -AutoFilter -FreezeTopRow -PassThru
$linkedServers = $excelLinkedServers.Workbook.Worksheets["Confirm Linked Servers"]

Add-ConditionalFormatting -WorkSheet $linkedServers -address $linkedServers.Dimension.Address -RuleType ContainsText -ConditionValue "OraOLEDB.Oracle" -BackgroundColor Yellow
Add-ConditionalFormatting -WorkSheet $linkedServers -address $linkedServers.Dimension.Address -RuleType ContainsText -ConditionValue "MSOLAP" -BackgroundColor Yellow

Close-ExcelPackage $excelLinkedServers
}


##### Generate Database Mail Tab ######

Write-Output "Generating Confirm Database Mail Tab for $AppSQLInstance"
# Prepare the base parameters
$params = @{
    ServerInstance = $SqlInstance
    Database = $DatabaseName
    Query = "EXEC mpa.ConfirmDatabaseMail @SQLInstance = '`$(InstanceParam)';"
    Variable = "InstanceParam=$AppSQLInstance"
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
$ConfirmDatabaseMail = Invoke-Sqlcmd @params
if($ConfirmDatabaseMail){
$ConfirmDatabaseMail | Export-Csv -Delimiter ";" -Path (Join-Path -Path $OutputFolder -ChildPath temp_database_mail.csv) -NoTypeInformation

Import-Csv -Path (Join-Path -Path $OutputFolder -ChildPath temp_database_mail.csv) -Delimiter ';' | Export-Excel -Path $OutputFile -AutoSize -BoldTopRow -WorksheetName 'Confirm Database Mail' -AutoFilter -FreezeTopRow
}


##### Generate sp_configure Tab ######

Write-Output "Generating Confirm SP Configure Tab for $AppSQLInstance"
# Prepare the base parameters
$params = @{
    ServerInstance = $SqlInstance
    Database = $DatabaseName
    Query = "EXEC mpa.ConfirmSPConfigure @SQLInstance = '`$(InstanceParam)';"
    Variable = "InstanceParam=$AppSQLInstance"
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
$ConfirmSpConfigure = Invoke-Sqlcmd @params

$ConfirmSpConfigureInformation = $ConfirmSpConfigure | ConvertTo-Csv -Delimiter ";" -NoTypeInformation

$excelSPConfigure = $ConfirmSpConfigureInformation | ConvertFrom-Csv -Delimiter ";" | Export-Excel -Path $OutputFile -AutoSize -BoldTopRow -WorksheetName 'Non-Default sp_configure' -AutoFilter -FreezeTopRow -PassThru

$spConfigure = $excelSPConfigure.Workbook.Worksheets["Non-Default sp_configure"]
Add-ConditionalFormatting -WorkSheet $spConfigure -address $spConfigure.Dimension.Address -RuleType ContainsText -ConditionValue "xp_cmdshell" -BackgroundColor Yellow
Add-ConditionalFormatting -WorkSheet $spConfigure -address $spConfigure.Dimension.Address -RuleType ContainsText -ConditionValue "Ole Automation Procedures" -BackgroundColor Yellow
Add-ConditionalFormatting -WorkSheet $spConfigure -address $spConfigure.Dimension.Address -RuleType ContainsText -ConditionValue "allow polybase export" -BackgroundColor Yellow
Add-ConditionalFormatting -WorkSheet $spConfigure -address $spConfigure.Dimension.Address -RuleType ContainsText -ConditionValue "filestream access level" -BackgroundColor Yellow
Add-ConditionalFormatting -WorkSheet $spConfigure -address $spConfigure.Dimension.Address -RuleType ContainsText -ConditionValue "hadoop connectivity" -BackgroundColor Yellow

Close-ExcelPackage $excelSPConfigure


##### Generate Database Users Tab ######

Write-Output "Generating Confirm Database Users Tab for $AppSQLInstance"
# Prepare the base parameters
$params = @{
    ServerInstance = $SqlInstance
    Database = $DatabaseName
    Query = "exec mpa.ConfirmDatabaseUsers @ApplicationName = '`$(AppNameParam)', @Environment = '`$(EnvironmentParam)';"
    Variable = @("AppNameParam=$ApplicationName", "EnvironmentParam=$AppEnvironment")
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
$ConfirmDatabaseUsers = Invoke-Sqlcmd @params

$ConfirmDatabaseUsersInformation = $ConfirmDatabaseUsers | ConvertTo-Csv -Delimiter ";" -NoTypeInformation

$excelUsers = $ConfirmDatabaseUsersInformation | ConvertFrom-Csv -Delimiter ";" | Export-Excel -Path $OutputFile -AutoSize -BoldTopRow -WorksheetName 'Confirm Database Users' -AutoFilter -FreezeTopRow -PassThru

$users = $excelUsers.Workbook.Worksheets["Confirm Database Users"]

Add-ConditionalFormatting -WorkSheet $users -address $users.Dimension.Address -RuleType ContainsText -ConditionValue "sysadmin" -BackgroundColor Yellow

Close-ExcelPackage $excelUsers


##### Generate CLR Objects Tab ######

Write-Output "Generating Confirm CLR Usage Tab for $AppSQLInstance"
# Prepare the base parameters
$params = @{
    ServerInstance = $SqlInstance
    Database = $DatabaseName
    Query = "exec mpa.ConfirmCLRUsage @ApplicationName = '`$(AppNameParam)', @Environment = '`$(EnvironmentParam)';"
    Variable = @("AppNameParam=$ApplicationName", "EnvironmentParam=$AppEnvironment")
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
$ConfirmCLR = Invoke-Sqlcmd @params

if($ConfirmCLR){
$ConfirmCLR | Export-Csv -Delimiter ";" -Path (Join-Path -Path $OutputFolder -ChildPath temp_clr_reports.csv) -NoTypeInformation

Import-Csv -Path (Join-Path -Path $OutputFolder -ChildPath temp_clr_reports.csv) -Delimiter ';' | Export-Excel -Path $OutputFile -AutoSize -BoldTopRow -WorksheetName 'Confirm CLR Usage' -AutoFilter -FreezeTopRow
}

##### Generate Server Credentials Tab ######

Write-Output "Generating Confirm Server Credentials Tab for $AppSQLInstance"
# Prepare the base parameters
$params = @{
    ServerInstance = $SqlInstance
    Database = $DatabaseName
    Query = "EXEC mpa.[ConfirmCredentials] @ApplicationName = '`$(AppNameParam)', @Environment = '`$(EnvironmentParam)';"
    Variable = @("AppNameParam=$ApplicationName", "EnvironmentParam=$AppEnvironment")
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
$ConfirmCredentials = Invoke-Sqlcmd @params

if($ConfirmCredentials){
$ConfirmCredentials | Export-Csv -Delimiter ";" -Path (Join-Path -Path $OutputFolder -ChildPath temp_credentials_reports.csv) -NoTypeInformation

Import-Csv -Path (Join-Path -Path $OutputFolder -ChildPath temp_credentials_reports.csv) -Delimiter ';' | Export-Excel -Path $OutputFile -AutoSize -BoldTopRow -WorksheetName 'Confirm Server Credentials' -AutoFilter -FreezeTopRow
}


##### Generate RDS Support Tab ######
Write-Output "Generating RDS Support Tab"
# Prepare the base parameters
$params = @{
    ServerInstance = $SqlInstance
    Database = $DatabaseName
    Query = "EXEC mpa.ConfirmRDSSupport @SQLInstance = '`$(InstanceParam)';"
    Variable = "InstanceParam=$AppSQLInstance"
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

$excel = $RDSSupportInformation | ConvertFrom-Csv -Delimiter ";" | Export-Excel -Path $OutputFile -AutoSize -BoldTopRow -WorksheetName 'RDS Support' -AutoFilter -FreezeTopRow -PassThru

$rds = $excel.Workbook.Worksheets["RDS Support"]

Add-ConditionalFormatting -WorkSheet $rds -address $rds.Dimension.Address -RuleType ContainsText -ConditionValue "False" -BackgroundColor LightGreen
Add-ConditionalFormatting -WorkSheet $rds -address $rds.Dimension.Address -RuleType ContainsText -ConditionValue "True" -BackgroundColor Yellow

Close-ExcelPackage $excel

}

# Prepare the base parameters
$params = @{
    ServerInstance = $SqlInstance
    Database = $DatabaseName
    Query = "SELECT master_app.ApplicationId,master_app.ApplicationName, Environment,SQLInstance,DatabaseName FROM mpa.master_applications as master_app JOIN mpa.master_databases as master_db ON master_db.ApplicationId = master_app.ApplicationId WHERE master_app.ApplicationName = '`$(AppNameParam)' AND master_db.Environment = '`$(EnvironmentParam)'"
    Variable = @("AppNameParam=$ApplicationName", "EnvironmentParam=$AppEnvironment")
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
$AppDatabaseInformation = Invoke-Sqlcmd @params

foreach($db in $AppDatabaseInformation){

##### Generate Database Dependency Tab ######

Write-Output "Generating Confirm Database Dependency Tab for $AppSQLInstance - $($db.DatabaseName)"
# Prepare the base parameters
$params = @{
    ServerInstance = $SqlInstance
    Database = $DatabaseName
    Query = "exec mpa.ConfirmDatabaseInterdependency @SQLInstance = '`$(InstanceParam)', @DatabaseName = '`$(DbNameParam)';"
    Variable = @("InstanceParam=$($db.SQLInstance)", "DbNameParam=$($db.DatabaseName)")
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
$ConfirmSpConfigure = Invoke-Sqlcmd @params
if($ConfirmSpConfigure){

$ConfirmSpConfigure | Export-Csv -Delimiter ";" -Path (Join-Path -Path $OutputFolder -ChildPath temp_db_dependencies_configure.csv) -NoTypeInformation

Import-Csv -Path (Join-Path -Path $OutputFolder -ChildPath temp_db_dependencies_configure.csv) -Delimiter ';' | Export-Excel -Path $OutputFile -AutoSize -BoldTopRow -WorksheetName 'Database Dependencies' -AutoFilter -FreezeTopRow

    }

##### Generate Downgrade Database to Standard Tab ######

Write-Output "Generating Confirm Confirm Downgrade To Standard Tab for $AppSQLInstance - $($db.DatabaseName)"
# Prepare the base parameters
$params = @{
    ServerInstance = $SqlInstance
    Database = $DatabaseName
    Query = "exec mpa.ConfirmDowngradeToStandard @SQLInstance = '`$(InstanceParam)', @DatabaseName = '`$(DbNameParam)';"
    Variable = @("InstanceParam=$($db.SQLInstance)", "DbNameParam=$($db.DatabaseName)")
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
$ConfirmDowngrade = Invoke-Sqlcmd @params
if($ConfirmDowngrade){

$ConfirmDowngrade | Export-Csv -Delimiter ";" -Path (Join-Path -Path $OutputFolder -ChildPath temp_downgrade_to_standard.csv) -NoTypeInformation

Import-Csv -Path (Join-Path -Path $OutputFolder -ChildPath temp_downgrade_to_standard.csv) -Delimiter ';' | Export-Excel -Path $OutputFile -AutoSize -BoldTopRow -WorksheetName 'Database Downgrade' -AutoFilter -FreezeTopRow

    }

}

Get-ChildItem -Path $OutputFolder -Filter '*.csv' | Remove-Item | Out-Null

}




else{
Write-Output "Application [$AppName] not found for Environment [$Environment]. Try again!"
}
