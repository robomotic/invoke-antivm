Function Get-CPU { 

	
    return Get-WmiObject –class Win32_processor | select systemname,Name,DeviceID,NumberOfCores,NumberOfLogicalProcessors, Addresswidth
} 


Function checkOldCPU{
    Param( 
    [Parameter( 
         Mandatory=$true, 
         Position=0, 
         ValueFromPipeline=$true, 
            ValueFromPipelineByPropertyName=$true)] 
        [Int]$MAX
    ) 
    Process{
    Foreach($cpu in Get-CPU)
    {

        if ($cpu.NumberOfCores)
        {
            if ($cpu.NumberOfCores -lt $MAX) {

                return $true
            }
        }

    }
    }
}