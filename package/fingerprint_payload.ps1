Import-Module Invoke-AntiVM
 
$json = Generate-Info

$json > "$((Get-Location).Path)\$($env:COMPUTERNAME).json"