function checkRunningProcesses
{
    $procs = ''
    $found = 0
    $values = @()

    $procs = Get-Process
    for ($i=0; $i -lt $procs.length; $i++)
    {
        # convert Get-Process object to string
        $proc = $procs[$i].ProcessName | Out-String
        $proc = $proc.ToLower().Trim()
        
        if ($proc.contains("vmtoolsd"))
        {
            $found = 1
            $values += "VMware - $($proc)"
        }
        elseif ($proc.contains("vmwaretrat"))
        {
            $found = 1
            $values += "VMware - $($proc)"
        }
        elseif ($proc.contains("vmwareuser"))
        {
            $found = 1
            $values += "VMware - $($proc)"
        }
        elseif ($proc.contains("vmacthlp"))
        {
            $found = 1
            $values += "VMware - $($proc)"
        }
        elseif ($proc.contains("vboxservice"))
        {
            $found = 1
            $values += "VirtualBox - $($proc)"
        }
        elseif ($proc.contains("vboxtray"))
        {
            $found = 1
            $values += "Virtualbox - $($proc)"
        }
    }
    if (-NOT $values)
    {
        $values += "No matching processes found"
    }
    
    return ($found, $values)
}

function checkRunningServices
{
    $services = ''
    $found = 0
    $values = @()

    $services = Get-Service
    for ($i=0; $i -lt $services.length; $i++)
    {
        # convert Get-Service object to string
        $service = $services[$i].ServiceName | Out-String
        $service = $service.ToLower().Trim()
        
        if ($service.contains("vmtools"))
        {
            $found = 1
            $values += "VMware - $($service)"
        }
        elseif ($service.contains("vmhgfs"))
        {
            $found = 1
            $values += "VMware - $($service)"
        }
        elseif ($service.contains("vmmemctl"))
        {
            $found = 1
            $values += "VMware - $($service)"
        }
        elseif ($service.contains("vmmouse"))
        {
            $found = 1
            $values += "VMware - $($service)"
        }
        elseif ($service.contains("vmrawdsk"))
        {
            $found = 1
            $values += "VMware - $($service)"
        }
        elseif ($service.contains("vmusbmouse"))
        {
            $found = 1
            $values += "VMware - $($service)"
        }
        elseif ($service.contains("vmvss"))
        {
            $found = 1
            $values += "VMware - $($service)"
        }
        elseif ($service.contains("vmscsi"))
        {
            $found = 1
            $values += "VMware - $($service)"
        }
        elseif ($service.contains("vmxnet"))
        {
            $found = 1
            $values += "VMware - $($service)"
        }
        elseif ($service.contains("vmx_svga"))
        {
            $found = 1
            $values += "VMware - $($service)"
        }
        elseif ($service.contains("vmware tools"))
        {
            $found = 1
            $values += "VMware - $($service)"
        }
        elseif ($service.contains("vmware physical disk helper service"))
        {
            $found = 1
            $values += "VMware - $($service)"
        }
    }
    if (-NOT $values)
    {
        $values += "No matching services found"
    }
    
    return ($found, $values)
}
