# resources:
#   https://resources.infosecinstitute.com/pafish-paranoid-fish/
#   https://www.thewindowsclub.com/clear-most-recently-used-mru-list
#   https://www.cyberbit.com/blog/endpoint-security/anti-vm-and-anti-sandbox-explained/
#       1) checking cpu instructions
#           - cpuid --> http://waynes-world-it.blogspot.com/2009/06/calling-cpuid-from-powershell-for-intel.html
#           - mmx
#           - in
#       2) known MAC addresses
#   http://webcache.googleusercontent.com/search?q=cache:FRZ2kko0NG8J:pentestit.com/al-khaser-benign-malware-test-anti-malware/+&cd=12&hl=en&ct=clnk&gl=us
#   https://github.com/nicehash/NiceHashMiner-Archived/blob/master/NiceHashMiner/PInvoke/CPUID.cs

function checkAdapters
{
    $adapters = ''
    
    Try
    {
        $adapters = Get-CimInstance -ClassName Win32_NetworkAdapter
        
    }
    Catch
    {
        # for older PowerShell versions
        $adapters = Get-WmiObject Win32_NetworkAdapter
    }
    return $adapters
}

function checkGateway
{
    param ( $interfaceIndex , $deviceID)
    $gateway = ''
    
    if ($interfaceIndex)
    {
        Try
        {
            $gateway = Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration -Filter "InterfaceIndex = $($interfaceIndex)"
        }
        Catch
        {
            $gateways = Get-WmiObject -Class Win32_NetworkAdapterConfiguration
            For($i=0; $i -lt $gateways.length; $i++)
            {
                If ($gateways[$i].Index -eq $interfaceIndex)
                {
                    $gateway = $gateways[$i]
                    break
                }
                Elseif ($gateways[$i].InterfaceIndex -eq $interfaceIndex)
                {
                    $gateway = $gateways[$i]
                    break
                }
            }
        }
    }
    else
    {
        Try
        {
            # older versions don't support InterfaceIndex
            #Get-WmiObject Win32_NetworkAdapterConfiguration | Get-Member -MemberType Property | Where-Object {$_.name -NotMatch "__"} | Write-Host
            $gateways = Get-WmiObject Win32_NetworkAdapterConfiguration
            For($i=0; $i -lt $gateways.length; $i++)
            {
                If ($gateways[$i].Index -eq $deviceID)
                {
                    $gateway = $gateways[$i]
                    break
                }
            }
        }
        Catch
        {
            Write-Host "How did you get here???"
        }
    }
    return $gateway    
}

function checkMACAddresses
{
    # https://docs.microsoft.com/en-us/windows/win32/cimwin32prov/win32-networkadapter
    $adapters = checkAdapters
    $gateway = ''
    $found = 0
    $values = @()
    
    ForEach ( $a in $adapters )
    {
        # check if "Connected" state
        if ($a.NetConnectionStatus -eq 2)
        {
            # cut down on FPs by checking to see if gateway IP has been set
            # this will still FP if gateway IP has been manually set
            # for older versions of the OS where InterfaceIndex property does not exist, use DeviceID
            $gateway = checkGateway $a.InterfaceIndex $a.DeviceID
            if ($gateway.DefaultIPGateway)
            {
                # -contains runs into regex, .contains is more specific
                if ( $a.MACAddress.contains("00:05:69") )
                {
                    $found = 1
                    $values += "VMWare MAC - $($a.MACAddress)"
                }
                elseif ( $a.MACAddress.contains("00:0C:29") )
                {
                    $found = 1
                    $values += "VMWare MAC - $($a.MACAddress)"
                }
                elseif ( $a.MACAddress.contains("00:1C:14") )
                {
                    $found = 1
                    $values += "VMWare MAC - $($a.MACAddress)"
                }
                elseif ( $a.MACAddress.contains("00:50:56") )
                {
                    $found = 1
                    $values += "VMWare MAC - $($a.MACAddress)"
                }
                elseif ( $a.MACAddress.contains("08:00:27") )
                {
                    $found = 1
                    $values += "VirtualBox MAC - $($a.MACAddress)"
                }
                else
                {
                    $values += "Unlisted MAC - $($a.MACAddress)"
                }
            }
        }
    }
    return ($found, $values)
}

function checkNICDescription
{
    # https://docs.microsoft.com/en-us/windows/win32/cimwin32prov/win32-networkadapter
    $adapters = checkAdapters
    $gateway = ''
    $found = 0
    $values = @()
    
    ForEach ( $a in $adapters )
    {
        # check if "Connected" state
        if ($a.NetConnectionStatus -eq 2)
        {
            # cut down on FPs by checking to see if gateway IP has been set
            # this will still FP if gateway IP has been manually set
            $gateway = checkGateway($a.InterfaceIndex)
            # for older versions of PS
            if (-NOT $gateway)
            {
                $gateway = checkGateway($a.DeviceID)
            }
            if ($gateway.DefaultIPGateway)
            {
                # -contains runs into regex, .contains is more specific
                if ( $a.Description.contains("VMware") )
                {
                    $found = 1
                    $values += "NIC.Description - $($a.Description)"
                }
                else
                {
                    $values += "NIC.Description - $($a.Description)"
                }
            }
        }
    }
    return ($found, $values)
}

function checkNICName
{
    # https://docs.microsoft.com/en-us/windows/win32/cimwin32prov/win32-networkadapter
    $adapters = checkAdapters
    $found = 0
    $values = @()
    
    ForEach ( $a in $adapters )
    {
        # check if "Connected" state
        if ($a.NetConnectionStatus -eq 2)
        {
            # cut down on FPs by checking to see if gateway IP has been set
            # this will still FP if gateway IP has been manually set
            $gateway = checkGateway($a.InterfaceIndex)
            # for older versions of PS
            if (-NOT $gateway)
            {
                $gateway = checkGateway($a.DeviceID)
            }
            if ($gateway.DefaultIPGateway)
            {
                # -contains runs into regex, .contains is more specific
                if ( $a.Name.contains("VMware") )
                {
                    $found = 1
                    $values += "NIC.Name - $($a.Name)"
                }
                else
                {
                    $values += "NIC.Name - $($a.Name)"
                }
            }
        }
    }
    return ($found, $values)
}

function checkNICManufacturer
{
    # https://docs.microsoft.com/en-us/windows/win32/cimwin32prov/win32-networkadapter
    $adapters = checkAdapters
    $gateway = ''
    $found = 0
    $values = @()
    
    ForEach ( $a in $adapters )
    {
        # check if "Connected" state
        if ($a.NetConnectionStatus -eq 2)
        {
            # cut down on FPs by checking to see if gateway IP has been set
            # this will still FP if gateway IP has been manually set
            $gateway = checkGateway($a.InterfaceIndex)
            # for older versions of PS
            if (-NOT $gateway)
            {
                $gateway = checkGateway($a.DeviceID)
            }
            if ($gateway.DefaultIPGateway)
            {
                # -contains runs into regex, .contains is more specific
                if ( $a.Manufacturer.contains("VMware") )
                {
                    $found = 1
                    $values += "NIC.Manufacturer - $($a.Manufacturer)"
                }
                else
                {
                    $values += "NIC.Manufacturer - $($a.Manufacturer)"
                }
            }
        }
    }
    return ($found, $values)
}

function checkNICProductName
{
    # https://docs.microsoft.com/en-us/windows/win32/cimwin32prov/win32-networkadapter
    $adapters = checkAdapters
    $found = 0
    $values = @()
    
    ForEach ( $a in $adapters )
    {
        # check if "Connected" state
        if ($a.NetConnectionStatus -eq 2)
        {
            # cut down on FPs by checking to see if gateway IP has been set
            # this will still FP if gateway IP has been manually set
            $gateway = checkGateway($a.InterfaceIndex)
            # for older versions of PS
            if (-NOT $gateway)
            {
                $gateway = checkGateway($a.DeviceID)
            }
            if ($gateway.DefaultIPGateway)
            {
                # -contains runs into regex, .contains is more specific
                if ( $a.ProductName.contains("VMware") )
                {
                    $found = 1
                    $values += "NIC.ProductName - $($a.ProductName)"
                }
                else
                {
                    $values += "NIC.ProductName - $($a.ProductName)"
                }
            }
        }
    }
    return ($found, $values)
}

function checkNICServiceName
{
    # https://docs.microsoft.com/en-us/windows/win32/cimwin32prov/win32-networkadapter
    $adapters = checkAdapters
    $found = 0
    $values = @()
    
    ForEach ( $a in $adapters )
    {
        # check if "Connected" state
        if ($a.NetConnectionStatus -eq 2)
        {
            # cut down on FPs by checking to see if gateway IP has been set
            # this will still FP if gateway IP has been manually set
            $gateway = checkGateway($a.InterfaceIndex)
            # for older versions of PS
            if (-NOT $gateway)
            {
                $gateway = checkGateway($a.DeviceID)
            }
            if ($gateway.DefaultIPGateway)
            {
                # -contains runs into regex, .contains is more specific
                if ( $a.ServiceName.contains("vmxnet") )
                {
                    $found = 1
                    $values += "NIC.ServiceName - $($a.ServiceName)"
                }
                else
                {
                    $values += "NIC.ServiceName - $($a.ServiceName)"
                }
            }
        }
    }
    return ($found, $values)
}

