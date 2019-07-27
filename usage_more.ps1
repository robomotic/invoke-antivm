Import-Module .\Invoke-AntiVM.psd1

$checks = @(Get-Item function:checkMACAddresses,
            function:checkNICDescription,
            function:checkNICManufacturer,
            function:checkNICProductName,
            function:checkNICServiceName,
            function:checkNICName
)


ForEach ($check in $checks)
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
    }
    ForEach ($v in $values)
    {
        if ($v)
        {
            Write-Host " - $v"
        }
    }
}

