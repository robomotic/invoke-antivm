Import-Module .\Invoke-AntiVM.psd1

$checks = @(Get-Item function:checkMACAddresses,
            function:checkNICDescription,
            function:checkNICManufacturer,
            function:checkNICProductName,
            function:checkNICServiceName,
            function:checkNICName,
            #function:checkRunningProcesses,
            #function:checkRunningServices,
            function:checkMouseMovement,
            function:checkKeyPress
)

foreach ($check in $checks)
{
    $found = 0
    $values = @()

    ($found, $values) = & $check

    if ($found)
    {
        Write-Host -ForegroundColor RED "VM FOUND"
    }
    else
    {
        Write-Host -ForegroundColor GREEN "VM NOT FOUND"
        if (-not $values)
        {
            Write-Host " + $check"
        }
    }

    foreach ($value in $values)
    {
        Write-Host " + $value"
    }
}
