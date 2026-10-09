#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

param (
    [Parameter(Mandatory = $true)]
    [string]$ServerName,
    [Parameter(Mandatory = $true)]
    [string]$OutputFolder
)

#$OutputFile = "$OutputFolder\FinalInventory.xlsx"
$OutputFile = Join-Path -Path $OutputFolder -ChildPath ($ServerName.Replace("\", "-") + "FinalInventory.xlsx")

$ExcelModule = Get-Module -Name ImportExcel -ListAvailable

if (!($ExcelModule)) {

    Install-Module ImportExcel -Scope CurrentUser

    Write-Output "ImportExcel Module has been installed"

}

if (Get-Item -Path $OutputFile -ErrorAction SilentlyContinue) {

    Remove-Item -Path $OutputFile -Force -Verbose

}


$Files = Get-ChildItem -Path $OutputFolder -Verbose
foreach ($file in $Files) {
    try {
        $WorksheetName = $($file.Name).Split(".")[0]

        Write-Output "Working on [$($file.FullName)]"

        Import-Csv -Path $file.FullName -Delimiter ';' | Export-Excel -Path $OutputFile -AutoSize -BoldTopRow -WorksheetName $WorksheetName  -AutoFilter -FreezeTopRow

    }
    catch {
        Write-Output $_
    }

}
