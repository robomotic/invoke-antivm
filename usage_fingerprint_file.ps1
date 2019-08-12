Import-Module .\Invoke-AntiVM.psd1

$json = Get-Info -Token "VmwareTest"

$json > "$((Get-Location).Path)\$($env:COMPUTERNAME).json"

