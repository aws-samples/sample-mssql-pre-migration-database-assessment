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
        Author:     Marcelo Fernandes (marcesl)
        Description: Script creation
        Date:       10/01/2021
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)][String]$ServerName,
    [Parameter(Mandatory = $true)][String]$ReportPath
)


#==================================================
# Variables
#==================================================

#$FilePath = Join-Path -Path $ReportPath -ChildPath ("HadwareInfo-"+$ServerName+"-$((Get-date).ToString("yyyyMMdd-HHmmss")).csv")
$FilePath = Join-Path -Path $ReportPath -ChildPath "HardwareInformationOS.csv"

    Write-Verbose "INFO ($ServerName): Getting system information"
    Try {
        $HardwareInfo = Get-CimInstance -ClassName 'Win32_ComputerSystem' -ComputerName $ServerName -ErrorAction Stop | Select-Object -Property 'Name', 'Manufacturer', 'Model', @{ Name = 'MemoryGB'; Expression = { $_.TotalPhysicalMemory / 1GB -as [int] } },'SystemType', 'Domain','NumberOfLogicalProcessors', 'NumberOfProcessors', 'HypervisorPresent', 'Roles'
        $OSInfo = Get-CimInstance -ClassName 'Win32_OperatingSystem' -ComputerName $ServerName -ErrorAction Stop | Select-Object -Property 'Caption', 'Version', 'OSArchitecture', 'LastBootUptime'
    } Catch [System.Exception] {
        Write-Output "ERROR ($ServerName): Failed to get system information $_"
        Exit 1
    }

    Switch ($HardwareInfo.Model) {
        'Virtual Machine' { $Plat = 'Virtual' }
        'VMware Virtual Platform' { $Plat = 'Virtual' }
        'VirtualBox' { $Plat = 'Virtual' }
        default {
            Switch ($HardwareInfo.Manufacturer) {
                'Amazon EC2' { $Plat = 'Virtual' }
                'Google' { $Plat = 'Virtual' }
                'QEMU' { $Plat = 'Virtual' }
                'Xen' { $Plat = 'Virtual' }
                default { $Plat = 'Physical' }
            }
        }
    }

    Write-Verbose "INFO ($ServerName): Getting Time Zone information"
    Try {
        $Timezone = Get-CimInstance -ClassName 'Win32_TimeZone' -ComputerName $ServerName | Select-Object -ExpandProperty 'Caption'
    } Catch [System.Exception] {
        Write-Output "ERROR ($ServerName): Failed to get Time Zone information $_"
        #Exit 1
    }

    $Output =@()
    $Output = [pscustomobject]@{
        'Device Name'             = $ServerName
        'Operating System'        = $OSInfo.Caption
        'OS Version'              = $OSInfo.Version
        'OS Architecture'         = $OSInfo.OSArchitecture
        'TimeZone'                = $Timezone
        'LastBootUptime'          = ($OSInfo.LastBootUptime).ToString("yyyy/MM/dd")
        'Domain'                  = $HardwareInfo.Domain
        'Uptime(Days)'            = ($OSInfo.LastBootUptime - (get-date)).Days
        'NumberOfProcessors'      = $HardwareInfo.NumberOfProcessors
        'NumberOfLogicalProcessors'= $HardwareInfo.NumberOfLogicalProcessors
        #'Avg CPU Util%'           = [math]::Round(($PerfCounterArray | Where-Object { $_.Name -eq 'CPU Utilization' } | Select-Object -ExpandProperty 'Avg'), 2)
        #'Max CPU Util%'           = [math]::Round(($PerfCounterArray | Where-Object { $_.Name -eq 'CPU Utilization' } | Select-Object -ExpandProperty 'Max'), 2)
        'Total RAM (GB)'          = $HardwareInfo.MemoryGB
        #'Avg Used RAM (GB)'       = [math]::Round((($HardwareInfo.MemoryGB) - ([int]($PerfCounterArray | Where-Object { $_.Name -eq 'Available RAM' } | Select-Object -ExpandProperty 'Avg') / 1024)), 2)
        #'Max Used RAM (GB)'       = [math]::Round((($HardwareInfo.MemoryGB) - ([int]($PerfCounterArray | Where-Object { $_.Name -eq 'Available RAM' } | Select-Object -ExpandProperty 'Max') / 1024)), 2)
        'Platform'                = $Plat
        'Manufacturer'            = $HardwareInfo.Manufacturer
        'Model'                   = $HardwareInfo.Model
    }

$Output | ConvertTo-Csv -NoTypeInformation -Delimiter ";" | Out-File $FilePath
Write-Verbose "INFO: Data gathering completed"

#Return $Output
