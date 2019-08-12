function checkRunningProcesses
{
    $vmcounts = @{} 

    $procs = Get-Process
    for ($i=0; $i -lt $procs.length; $i++)
    {
        # for all the processes retrieve only the normalized name
        $proc = $procs[$i].ProcessName | Out-String
        $procname = $proc.ToLower().Trim()
        
        #Vmware detections
        if (($procname -eq "vmusrvc.exe") -or ($procname -match "vmsrvc.exe"))
        {
            if( $vmcounts.vmware ){
                $vmcounts.vmware += 1
            }
            else{
                $vmcounts.vmware = 0
            }
        }
        elif ($procname.contains("vmtoolsd"))
        {
            if( $vmcounts.vmware ){
                $vmcounts.vmware += 1
            }
            else{
                $vmcounts.vmware = 1
            }
        }
        elseif (($procname -match "vmwaretray.exe") -or ($procname -eq "vmwareuser.exe"))
        {
            if( $vmcounts.vmware ){
                $vmcounts.vmware += 1
            }
            else{
                $vmcounts.vmware = 1
            }
        }
        elseif ( ($procname.contains("vmwaretrat")) -or (procname.contains("vmacthlp")))
        {
            if( $vmcounts.vmware ){
                $vmcounts.vmware += 1
            }
            else{
                $vmcounts.vmware = 1
            }

        }

        #Virtual Box detections
        if ($procname.contains("vboxservice") -or ($procname.contains("vboxtray")))
        {
            if( $vmcounts.virtualbox ){
                $vmcounts.virtualbox += 1
            }
            else{
                $vmcounts.virtualbox = 1
            }
        }
        # Xen detections
        if ($procname -eq "xenservice.exe")
        {
            if( $vmcounts.xenservice ){
                $vmcounts.xenservice += 1
            }
            else{
                $vmcounts.xenservice = 1
            }
        }
    }
    if (-NOT $values)
    {
        $values += "No matching processes found"
    }
    
    return ($vmcounts.Count, $vmcounts)
}

function checkRunningServices
{
    $vmcounts = @{} 

    $services = Get-Service
    for ($i=0; $i -lt $services.length; $i++)
    {
        # convert Get-Service object to string
        $service = $services[$i].ServiceName | Out-String
        $service = $service.ToLower().Trim()
        
        if ($service.contains("vmtools"))
        {
            if( $vmcounts.vmware ){
                $vmcounts.vmware += 1
            }
            else{
                $vmcounts.vmware = 1
            }
        }
        elseif ($service.contains("vmhgfs"))
        {
            if( $vmcounts.vmware ){
                $vmcounts.vmware += 1
            }
            else{
                $vmcounts.vmware = 1
            }
        }
        elseif ($service.contains("vmmemctl"))
        {
            if( $vmcounts.vmware ){
                $vmcounts.vmware += 1
            }
            else{
                $vmcounts.vmware = 1
            }
        }
        elseif ($service.contains("vmmouse"))
        {
            if( $vmcounts.vmware ){
                $vmcounts.vmware += 1
            }
            else{
                $vmcounts.vmware = 1
            }
        }
        elseif ($service.contains("vmrawdsk"))
        {
            if( $vmcounts.vmware ){
                $vmcounts.vmware += 1
            }
            else{
                $vmcounts.vmware = 1
            }
        }
        elseif ($service.contains("vmusbmouse"))
        {
            if( $vmcounts.vmware ){
                $vmcounts.vmware += 1
            }
            else{
                $vmcounts.vmware = 1
            }
        }
        elseif ($service.contains("vmvss"))
        {
            if( $vmcounts.vmware ){
                $vmcounts.vmware += 1
            }
            else{
                $vmcounts.vmware = 1
            }
        }
        elseif ($service.contains("vmscsi"))
        {
            if( $vmcounts.vmware ){
                $vmcounts.vmware += 1
            }
            else{
                $vmcounts.vmware = 1
            }
        }
        elseif ($service.contains("vmxnet"))
        {
            if( $vmcounts.vmware ){
                $vmcounts.vmware += 1
            }
            else{
                $vmcounts.vmware = 1
            }
        }
        elseif ($service.contains("vmx_svga"))
        {
            if( $vmcounts.vmware ){
                $vmcounts.vmware += 1
            }
            else{
                $vmcounts.vmware = 1
            }
        }
        elseif ($service.contains("vmware tools"))
        {
            if( $vmcounts.vmware ){
                $vmcounts.vmware += 1
            }
            else{
                $vmcounts.vmware = 1
            }
        }
        elseif ($service.contains("vmware physical disk helper service"))
        {
            if( $vmcounts.vmware ){
                $vmcounts.vmware += 1
            }
            else{
                $vmcounts.vmware = 1
            }
        }
    }

    return ($vmcounts.Count, $vmcounts)
}
