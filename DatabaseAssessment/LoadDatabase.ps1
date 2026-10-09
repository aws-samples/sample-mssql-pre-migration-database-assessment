#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

<#
    .SYNOPSIS
    LoadDatabase.ps1

    .DESCRIPTION
    Loads consolidated CSV assessment files into the AwsDatabaseAssessment database.

    .PARAMETER SqlInstance
        The SQL Server instance name where the assessment database resides. Defaults to the local computer name.

    .PARAMETER DatabaseName
        The name of the assessment database. Defaults to 'AwsDatabaseAssessment'.

    .PARAMETER AssessmentSchema
        The schema where raw assessment data is loaded. Defaults to 'raw'.

    .EXAMPLE
    .\LoadDatabase.ps1

    .EXAMPLE
    .\LoadDatabase.ps1 -SqlInstance "SERVER01\SQLEXPRESS"

    .EXAMPLE
    .\LoadDatabase.ps1 -SqlInstance "SERVER01" -DatabaseName "MyAssessmentDB" -AssessmentSchema "staging"

    .NOTES
        Author: Marcos Freccia (mfreccia)
#>

param (
    [Parameter(Mandatory = $false)]
    [string]$SqlInstance = $Env:COMPUTERNAME,

    [Parameter(Mandatory = $false)]
    [string]$DatabaseName = "AwsDatabaseAssessment",

    [Parameter(Mandatory = $false)]
    [string]$AssessmentSchema = "raw"
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

$SqlServerModuleExists = Get-Module SqlServer -ListAvailable

If(!($SqlServerModuleExists)){
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Install-Module -Name SqlServer -AllowClobber -Scope AllUsers

}

if (![System.Environment]::GetEnvironmentVariables()['DB_ASSESSMENT_HOME']){
    Throw "DB_ASSESSMENT_HOME doesn't exist. Create it, before proceeding"
}
(Get-Culture).NumberFormat.NumberDecimalSeparator = ','

$ConsolidatedFolder = Join-Path $Env:DB_ASSESSMENT_HOME -ChildPath "ConsolidatedFiles"

# Check if ConsolidatedFiles folder exists
if (!(Test-Path -Path $ConsolidatedFolder)) {
    Throw "ConsolidatedFiles folder not found at '$ConsolidatedFolder'. Run ConsolidateFiles.ps1 first."
}

$Files = Get-ChildItem -Path $ConsolidatedFolder -Filter '*.csv'

if ($Files.Count -eq 0) {
    Throw "No CSV files found in '$ConsolidatedFolder'. Run ConsolidateFiles.ps1 first."
}

# Check if database exists, create if not
Write-Output "Checking if database '$DatabaseName' exists on '$SqlInstance'..."
$params = @{
    ServerInstance = $SqlInstance
    Database = "master"
    Query = "SELECT COUNT(*) AS DbExists FROM sys.databases WHERE name = '$DatabaseName'"
}
if (Test-CommandParameter -CommandName "Invoke-Sqlcmd" -ParameterName "TrustServerCertificate") {
    $params.TrustServerCertificate = $true
}
if (Test-CommandParameter -CommandName "Invoke-Sqlcmd" -ParameterName "Encrypt") {
    $params.Encrypt = "Mandatory"
}

try {
    $dbExists = Invoke-Sqlcmd @params
    if ($dbExists.DbExists -eq 0) {
        Write-Output "Database '$DatabaseName' does not exist. Creating database schema..."
        
        # Find the AwsDatabaseAssessment.sql file
        $ScriptFolder = Split-Path -Parent $MyInvocation.MyCommand.Path
        $SqlScriptPath = Join-Path $ScriptFolder "AwsDatabaseAssessment.sql"
        
        if (!(Test-Path -Path $SqlScriptPath)) {
            Throw "Database creation script not found at '$SqlScriptPath'. Cannot create database."
        }
        
        Write-Output "Deploying database from '$SqlScriptPath'..."
        
        # Build parameters for Invoke-Sqlcmd with InputFile
        $deployParams = @{
            ServerInstance = $SqlInstance
            InputFile = $SqlScriptPath
        }
        if (Test-CommandParameter -CommandName "Invoke-Sqlcmd" -ParameterName "TrustServerCertificate") {
            $deployParams.TrustServerCertificate = $true
        }
        if (Test-CommandParameter -CommandName "Invoke-Sqlcmd" -ParameterName "Encrypt") {
            $deployParams.Encrypt = "Mandatory"
        }
        
        Invoke-Sqlcmd @deployParams
        Write-Output "Database '$DatabaseName' created successfully."
    } else {
        Write-Output "Database '$DatabaseName' already exists."
    }
} catch {
    Throw "Failed to check/create database: $($_.Exception.Message)"
}


# Run cleanup stored procedure if it exists
Write-Output "Checking for cleanup stored procedure..."
$params = @{
    ServerInstance = $SqlInstance
    Database = $DatabaseName
    Query = "SELECT COUNT(*) AS ProcExists FROM sys.procedures WHERE name = 'spCleanUpAssessmentDatabase'"
}
if (Test-CommandParameter -CommandName "Invoke-Sqlcmd" -ParameterName "TrustServerCertificate") {
    $params.TrustServerCertificate = $true
}
if (Test-CommandParameter -CommandName "Invoke-Sqlcmd" -ParameterName "Encrypt") {
    $params.Encrypt = "Mandatory"
}

try {
    $procExists = Invoke-Sqlcmd @params
    if ($procExists.ProcExists -gt 0) {
        Write-Output "Running spCleanUpAssessmentDatabase..."
        $params.Query = "EXEC [dbo].[spCleanUpAssessmentDatabase];"
        Invoke-Sqlcmd @params | Out-Null
    } else {
        Write-Warning "Stored procedure [dbo].[spCleanUpAssessmentDatabase] not found. Skipping cleanup. If this is the first load, this is expected. Otherwise, deploy AwsDatabaseAssessment.sql first."
    }
} catch {
    Write-Warning "Could not run cleanup procedure: $($_.Exception.Message)"
}

# Track our jobs with a hashtable mapping job ID to file name
$jobTracker = @{}

foreach($fl in $Files){
    $running = @(Get-Job | Where-Object { $_.State -eq 'Running' -and $jobTracker.ContainsKey($_.Id) })
    if ($running.Count -ge 4) {
        $running | Wait-Job -Any | Out-Null
    }
    Write-Output "Starting job for importing the file: [$($fl.Name)]"
    $job = Start-Job -Name "Import_$($fl.BaseName)" -ScriptBlock {
        param($FileName,$FullFileName,$FileLength,$SqlInstance,$AssessmentSchema,$DatabaseName)

        $tableName = $FileName.Split(".")[0]

        if($FileLength -gt 0){
            try{
                Write-Output "Trying to import $FileName"
                
                # First, get the table's column order from SQL Server
                $columnQuery = @"
SELECT COLUMN_NAME 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = '$AssessmentSchema' AND TABLE_NAME = '$tableName'
ORDER BY ORDINAL_POSITION
"@
                $tableColumns = Invoke-Sqlcmd -ServerInstance $SqlInstance -Database $DatabaseName -Query $columnQuery -TrustServerCertificate
                $columnOrder = $tableColumns | ForEach-Object { $_.COLUMN_NAME }
                
                if (-not $columnOrder -or $columnOrder.Count -eq 0) {
                    Write-Output "Warning: Could not get column order for table $tableName. Skipping."
                    return
                }
                
                $RawData = Import-Csv -Path $FullFileName -Delimiter ";"
                
                if ($RawData.Count -eq 0) {
                    Write-Output "File $FileName has no data rows to import."
                    return
                }
                
                # Get the CSV column names
                $csvColumns = $RawData[0].PSObject.Properties.Name
                
                # Build data with columns in the correct order for the table
                $InputData = @()
                foreach ($row in $RawData) {
                    $orderedRow = [ordered]@{}
                    foreach ($col in $columnOrder) {
                        # Find matching CSV column (case-insensitive)
                        $csvCol = $csvColumns | Where-Object { $_ -ieq $col } | Select-Object -First 1
                        if ($csvCol) {
                            $value = $row.$csvCol
                            if ([string]::IsNullOrWhiteSpace($value)) {
                                $orderedRow[$col] = $null
                            } else {
                                $orderedRow[$col] = $value
                            }
                        } else {
                            # Column exists in table but not in CSV - set to null
                            $orderedRow[$col] = $null
                        }
                    }
                    $InputData += [PSCustomObject]$orderedRow
                }
                
                if ($InputData.Count -gt 0) {
                    Write-SqlTableData -InputData $InputData -ServerInstance $SqlInstance -DatabaseName $DatabaseName -SchemaName $AssessmentSchema -TableName $tableName -TrustServerCertificate -Force
                    Write-Output "File $FileName imported successfully! ($($InputData.Count) rows)"
                } else {
                    Write-Output "File $FileName has no data rows to import."
                }
            }
            catch{
                Write-Output "Failed to import $tableName"
                Write-Error $_
            }
        } else {
            Write-Output "Skipping $FileName - file is empty (0 bytes)"
        }
    } -ArgumentList $fl.Name,$fl.FullName,$fl.Length,$SqlInstance,$AssessmentSchema,$DatabaseName
    
    # Track this job
    $jobTracker[$job.Id] = $fl.Name
}
# Wait for all jobs to complete
Write-Output ""
Write-Output "Waiting for all import jobs to complete..."
While (Get-Job | Where-Object { $_.State -eq 'Running' -and $jobTracker.ContainsKey($_.Id) })
{
    Start-Sleep 2
}

# Get results from all our tracked jobs
$failedFiles = @()
$successCount = 0

foreach ($jobId in $jobTracker.Keys) {
    $job = Get-Job -Id $jobId -ErrorAction SilentlyContinue
    if ($job) {
        $fileName = $jobTracker[$jobId]
        try {
            $output = Receive-Job -Job $job -ErrorAction Stop
            if ($output) {
                $output | ForEach-Object { Write-Output $_ }
            }
            $successCount++
        }
        catch {
            Write-Warning "Error processing $fileName : $($_.Exception.Message)"
            $failedFiles += $fileName
        }
        finally {
            Remove-Job -Job $job -Force -ErrorAction SilentlyContinue
        }
    }
}

if ($failedFiles.Count -gt 0) {
    Write-Warning ""
    Write-Warning "The following files had import issues:"
    $failedFiles | ForEach-Object { Write-Warning "  - $_" }
}

# Run SSIS fix stored procedure if it exists
Write-Output "Checking for SSIS fix stored procedure..."
$params = @{
    ServerInstance = $SqlInstance
    Database = $DatabaseName
    Query = "SELECT COUNT(*) AS ProcExists FROM sys.procedures WHERE name = 'FixSSIS_packages_connection_type_ssisdb'"
}
if (Test-CommandParameter -CommandName "Invoke-Sqlcmd" -ParameterName "TrustServerCertificate") {
    $params.TrustServerCertificate = $true
}
if (Test-CommandParameter -CommandName "Invoke-Sqlcmd" -ParameterName "Encrypt") {
    $params.Encrypt = "Mandatory"
}

try {
    $procExists = Invoke-Sqlcmd @params
    if ($procExists.ProcExists -gt 0) {
        Write-Output "Running FixSSIS_packages_connection_type_ssisdb..."
        $params.Query = "EXEC [dbo].[FixSSIS_packages_connection_type_ssisdb];"
        Invoke-Sqlcmd @params | Out-Null
        Write-Output "SSIS package names fixed successfully."
    } else {
        Write-Warning "Stored procedure [dbo].[FixSSIS_packages_connection_type_ssisdb] not found. Skipping SSIS fix. Deploy AwsDatabaseAssessment.sql to enable this feature."
    }
} catch {
    Write-Warning "Could not run SSIS fix procedure: $($_.Exception.Message)"
}

Write-Output ""
Write-Output "============================================"
Write-Output "        LOAD DATABASE COMPLETE"
Write-Output "============================================"
Write-Output "Files found:      $($Files.Count)"
Write-Output "Files processed:  $successCount"
if ($failedFiles.Count -gt 0) {
    Write-Output "Files with issues: $($failedFiles.Count)"
}
Write-Output "Target database:  $DatabaseName on $SqlInstance"
Write-Output ""
