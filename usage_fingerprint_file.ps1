Import-Module .\Invoke-AntiVM.psd1

$uptime = Get-Uptime

Write-Host $uptime
 
$json = Generate-Info

$json > "$((Get-Location).Path)\$($env:COMPUTERNAME).json"