#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

<#
    .SYNOPSIS
    invoke-Assessment.ps1

    .DESCRIPTION
    This script collects various information on Microsoft SQL Servers.

    .PARAMETER ServerName
        The SQL Server Instance name. If the target is a named Instance , it must have host\instance name e.g. SERVER1\PROD

    .PARAMETER ScriptFolder
        The folder location tothe .SQL files to be executed

    .EXAMPLE
    .# Manually add servers
    .\invoke-Assessment.ps1 -ServerName 'Server1', 'Server2' -ScriptFolder 'C:\Temp'

    # Pull servers from a list
    .\invoke-Assessment.ps1 -ServerName (Get-Content -Path 'C:\Temp\Servers.csv') -ScriptFolder 'C:\Temp'

    .NOTES
        Author:     Marcelo Fernandes (marcesl)
        Description: Script creation
        Date:       10/01/2021
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)][String[]]$ServerName,
    [Parameter(Mandatory = $true)][String]$ScriptFolder = (Get-Location)
)


[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12


#==================================================
# Variables
#==================================================

$AssessmentFilePath = Join-Path -Path $ScriptFolder -ChildPath "Assessment.ps1"
$InventoryFilePath = Join-Path -Path $ScriptFolder -ChildPath "InventoryGeneration.ps1"

#==================================================
# Execution
#==================================================

If (-Not (Test-Path -Path $AssessmentFilePath)) {
    Write-Output 'ERROR: Script path is invalid'
    Exit 1
}

[System.Collections.ArrayList]$Jobs = @()
Foreach ($Server in $ServerName) {
    Write-Output "INFO ($Server): Data gathering starting"
    #[void]$Jobs.Add($(Start-Job -ScriptBlock ${Function:Get-SQLServerInfo} -ArgumentList $Server))
    [void]$Jobs.Add($(Start-Job -FilePath $AssessmentFilePath -ArgumentList $ScriptFolder,$Server))
}

[System.Collections.ArrayList]$Outputs = @()
Do {
    Start-Sleep 2
    ForEach ($Job in $Jobs.Clone()) {
        $JobStatus = Get-Job -Id $Job.Id
        If ($JobStatus.State -ne 'Running') {
            $Output = Receive-Job -Job $Job | Select-Object -Property '*' -ExcludeProperty 'PSComputerName', 'RunspaceID', 'PSShowComputerName'
            [void]$Outputs.Add($Output)
            Remove-Job -Job $Job
            $Jobs.Remove($Job)
        }
    }
} While ($Jobs)



#==================================================
# Inventory generation
#==================================================

Foreach ($Server in $ServerName) {
    $OutputFolder = Join-Path -Path $ScriptFolder -ChildPath ("output-"+$Server)
    Write-Output "INFO ($Server): Data Generation started"
    #[void]$Jobs.Add($(Start-Job -ScriptBlock ${Function:Get-SQLServerInfo} -ArgumentList $Server))
    [void]$Jobs.Add($(Start-Job -FilePath $InventoryFilePath -ArgumentList $Server,$OutputFolder))
}


[System.Collections.ArrayList]$OutputsReports = @()
Do {
    Start-Sleep 2
    ForEach ($Job in $Jobs.Clone()) {
        $JobStatus = Get-Job -Id $Job.Id
        If ($JobStatus.State -ne 'Running') {
            $Output = Receive-Job -Job $Job | Select-Object -Property '*' -ExcludeProperty 'PSComputerName', 'RunspaceID', 'PSShowComputerName'
            [void]$OutputsReports.Add($Output)
            Remove-Job -Job $Job
            $Jobs.Remove($Job)
        }
    }
} While ($Jobs)

Write-Output "INFO: Data gathering completed"


#==================================================
# Compression
#==================================================

<#
Foreach ($Server in $ServerName) {
    $OutputFolder = Join-Path -Path $ScriptFolder -ChildPath ("output-"+$Server)
    Write-Output "INFO ($Server): Data compression started"
    $zipfilename = $OutputFolder+'.zip'

    $Files=Get-ChildItem  -path $OutputFolder  -Recurse

    if(-not (test-path -literalPath ($zipfilename)))
	    {
		    set-content -literalPath $zipfilename ("PK" + [char]5 + [char]6 + ("$([char]0)" * 18))
		    (dir -literalPath $zipfilename).IsReadOnly = $false
	    }

    foreach ($File in $Files)
    {
        $shellApplication = new-object -com shell.application
        $zipPackage = $shellApplication.NameSpace($zipfilename)
        $Checks=$zipPackage.Items() | Select name

        $zipPackage.CopyHere($File.FullName,4)
		    start-sleep -milliseconds 5000
    }
    Write-Output "Files are compressed in $zipfilename" -Foregroundcolor Yellow
}
#>

Write-Output "INFO: Assessment completed"
