Write-Output "Install PSScriptAnalyzer"
Install-Module PSScriptAnalyzer -Scope CurrentUser -Confirm:$False -Force

Write-Output "Check PSScriptAnalyzer.ps1"

$ResultsArray = @()
$Files = Get-ChildItem -Path 'DatabaseAssessment/' -Filter "*.ps1" -Recurse
foreach ($file in $Files) {
    $result = Invoke-ScriptAnalyzer -Path $file.FullName
    Write-Output ($result | Format-Table | Out-String)
}
