Function Get-DecodeMRU { 
<#
.SYNOPSIS

Decode the MRU cache.
Author:  Paolo Di Prodi (@robomotic)

.DESCRIPTION


.PARAMETER MRU

The registry key that contains the information for that particular program.


.EXAMPLE

$recent = Get-DecodeMRU -MRU "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\LastVisitedPidlMRU" 
   
#>

    Param( 
    [Parameter( 
         Mandatory=$true, 
         Position=0, 
         ValueFromPipeline=$true, 
            ValueFromPipelineByPropertyName=$true)] 
        [string]$MRU 
    ) 
    Try { 
        $items = Get-Item -Path $MRU | select -ExpandProperty Property         
        $data = @() 
        foreach ($item in $items) {            
                $name = $item           
                $valuekind = $($(Get-Item $MRU).GetValueKind("$name")) 
                 $bin = (Get-ItemProperty -Path $MRU -Name $name -ErrorAction SilentlyContinue)."$name"             
                 If ($valuekind -eq "BINARY") { 
                    $decoded = @() 
                    $asciirange = 32..126 
                    foreach ($dec in $bin) { 
                        If ($asciirange -like $dec) { 
                            $decoded += [char]$dec 
                            } 
                     }             
                } 
                 $data += New-Object -TypeName psobject -Property @{'Path'="$MRU\$name";'BinaryValue'=$bin;'DecodedValue'=$($decoded -join "");'Type'=$valuekind}             
                          
            } 
    } Catch { 
    } 
    return $data 
} 

Function loadRecentExplorerFiles{

$recent = Get-DecodeMRU -MRU "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\LastVisitedPidlMRU" 

return $recent

}


Function checkRecentExplorerFiles{

    Param( 
    [Parameter( 
         Mandatory=$true, 
         Position=0, 
         ValueFromPipeline=$true, 
            ValueFromPipelineByPropertyName=$true)] 
        [Int]$MAX
    ) 
    Process{
        $recent = loadRecentExplorerFiles
         if ($recent.count -lt $MAX) {
         return $true}
         else {return $false}
    }
}

