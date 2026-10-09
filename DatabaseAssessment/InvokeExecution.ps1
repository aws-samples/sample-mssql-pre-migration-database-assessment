#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

if (![System.Environment]::GetEnvironmentVariables()['DB_ASSESSMENT_HOME']){
    Throw "DB_ASSESSMENT_HOME doesn't exist. Create it, before proceeding"
}

# Start audit logging
$TranscriptPath = Join-Path -Path $Env:DB_ASSESSMENT_HOME -ChildPath "assessment-log-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"
Start-Transcript -Path $TranscriptPath -Append

Write-Output $Env:DB_ASSESSMENT_HOME
$AssessmentFolder = $Env:DB_ASSESSMENT_HOME # Update if necessary only
$ServerList = Get-Content (Join-Path $AssessmentFolder -ChildPath ServerList.txt) | Where-Object { $_.Trim() -ne '' }

if ($ServerList.Count -eq 0) {
    Write-Error "ServerList.txt is empty or contains no valid server names."
    exit 1
}

$AssessmentPsScript = Get-ChildItem -Path "$AssessmentFolder\mssql-pre-database-assessment\"  -Filter 'Assessment.ps1'
$ScriptOutputFolder = "$AssessmentFolder\mssql-pre-database-assessment"

$totalServers = $ServerList.Count
$currentServer = 0
$failedServers = @()
$successfulServers = @()

foreach($srv in $ServerList){
    $currentServer++
    $percentComplete = ($currentServer / $totalServers) * 100

    Write-Progress -Activity "Running SQL Server Assessment" -Status "Processing server $srv ($currentServer of $totalServers)" -PercentComplete $percentComplete

    try {
        & $AssessmentPsScript.FullName -ScriptFolder $ScriptOutputFolder -ServerName $srv -Verbose -ErrorAction Stop
        $successfulServers += $srv
    }
    catch {
        $errorMessage = $_.Exception.Message
        Write-Warning "Failed to assess server [$srv]: $errorMessage"
        $failedServers += [PSCustomObject]@{
            Server = $srv
            Error  = $errorMessage
        }
    }
}

Write-Progress -Activity "Running SQL Server Assessment" -Completed

# Summary
Write-Output ""
Write-Output "============================================"
Write-Output "           ASSESSMENT SUMMARY"
Write-Output "============================================"
Write-Output "Total servers in list: $totalServers"
Write-Output "Successfully assessed: $($successfulServers.Count)"
Write-Output "Failed to assess:      $($failedServers.Count)"
Write-Output ""

if ($successfulServers.Count -gt 0) {
    Write-Output "Successful servers:"
    $successfulServers | ForEach-Object { Write-Output "  [OK] $_" }
    Write-Output ""
}

if ($failedServers.Count -gt 0) {
    Write-Output "Failed servers:"
    $failedServers | ForEach-Object { 
        Write-Output "  [FAILED] $($_.Server)"
        Write-Output "           Error: $($_.Error)"
    }
    Write-Output ""
    Write-Warning "Some servers could not be assessed. Check the error messages above for details."
}

# Stop audit logging
Stop-Transcript
Write-Output "Assessment log saved to: $TranscriptPath"
