
function WMIInv ([string]$Name, [string]$query, [string]$namespace = "root\cimv2") {
    <#
.SYNOPSIS

Format the WMI call into JSON
Author:  Paolo Di Prodi (@robomotic)

From: https://github.com/rzander/DocumentDB-Inventory/blob/master/Inventory%20Agents/Windows-Devices/Create-Inventory.ps1
   
#>
    $jsonout = ",`n `"$($Name)`":" 
    $val += Get-WmiObject -Namespace $namespace -Query $query -ea SilentlyContinue | Select-Object * -ExcludeProperty Scope, Options, ClassPath, Properties, SystemProperties, Qualifiers, Site, Container, PSComputerName, Path, __* | Sort | ConvertTo-Json
    if ($null -eq $val) { $val = " null" } 
    $jsonout += $val
    return $jsonout
}

function GetPublicIP() {
    $json = Invoke-RestMethod http://ipinfo.io/json

    $obj = New-Object psobject
    Add-Member -InputObject $obj -MemberType NoteProperty -Name ipv4 -Value $json.ip
    Add-Member -InputObject $obj -MemberType NoteProperty -Name city -Value $json.city
    Add-Member -InputObject $obj -MemberType NoteProperty -Name region -Value $json.region
    Add-Member -InputObject $obj -MemberType NoteProperty -Name country -Value $json.country
    Add-Member -InputObject $obj -MemberType NoteProperty -Name location -Value $json.loc
    return $obj
}

function registry_values($regkey, $regvalue, $child) { 
    if ($child -eq "no") { $key = get-item $regkey } 
    else { $key = get-childitem $regkey } 
    $key | 
    ForEach-Object { 
        $values = Get-ItemProperty $_.PSPath 
        ForEach ($value in $_.Property) { 
            if ($regvalue -eq "all") { $values.$value } 
            elseif ($regvalue -eq "allname") { $value } 
            else { $values.$regvalue; break } 
        }
    }
}

function GetUTDate() {
    $date = get-date
    $date = $date.ToUniversalTime();
    return $date.ToString("r", [System.Globalization.CultureInfo]::InvariantCulture);
}

function Get-RegistryUninstallKey {
    #Inspied by: https://smsagent.blog/2015/10/15/searching-the-registry-uninstall-key-with-powershell/
    param([switch]$Wow6432Node)
    $results = @()
    Get-ChildItem HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall | 
    ForEach-Object {

        $DisplayName = $_.GetValue("DisplayName")

        If ($DisplayName -AND $DisplayName -notmatch '^Update  for|rollup|^Security Update|^Service Pack|^HotFix') {

            $obj = New-Object psobject
            Add-Member -InputObject $obj -MemberType NoteProperty -Name GUID -Value $_.pschildname
            Add-Member -InputObject $obj -MemberType NoteProperty -Name DisplayName -Value $_.GetValue("DisplayName")

            $Date = $_.GetValue('InstallDate')

            If ($Date) {

                Try {

                    $Date = [datetime]::ParseExact($Date, 'yyyyMMdd', $Null)

                }
                Catch {

                    Write-Warning "$($Computer): $_ <$($Date)>"

                    $Date = $Null

                }

            } 

            Add-Member -InputObject $obj -MemberType NoteProperty -Name DisplayVersion -Value $_.GetValue("DisplayVersion")
            if ($Wow6432Node)
            { Add-Member -InputObject $obj -MemberType NoteProperty -Name Wow6432Node? -Value "No" }
            $results += $obj
            
        }

    }
 
    if ($Wow6432Node) {
        $keys = Get-ChildItem HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall | 
        ForEach-Object {
            $obj = New-Object psobject
            Add-Member -InputObject $obj -MemberType NoteProperty -Name GUID -Value $_.pschildname

            If ($DisplayName -AND $DisplayName -notmatch '^Update  for|rollup|^Security Update|^Service Pack|^HotFix') {

                $obj = New-Object psobject
                Add-Member -InputObject $obj -MemberType NoteProperty -Name GUID -Value $_.pschildname
                Add-Member -InputObject $obj -MemberType NoteProperty -Name DisplayName -Value $_.GetValue("DisplayName")
    
                $Date = $_.GetValue('InstallDate')
    
                If ($Date) {
    
                    Try {
    
                        $Date = [datetime]::ParseExact($Date, 'yyyyMMdd', $Null)
    
                    }
                    Catch {
    
                        Write-Warning "$($Computer): $_ <$($Date)>"
    
                        $Date = $Null
    
                    }
    
                } 
            }

            Add-Member -InputObject $obj -MemberType NoteProperty -Name DisplayVersion -Value $_.GetValue("DisplayVersion")
            Add-Member -InputObject $obj -MemberType NoteProperty -Name Wow6432Node? -Value "Yes"
            $results += $obj
        }
    }
    return $results | Sort-Object DisplayName
} 


function Format-TimeSpan {
    process {
        "{0:00} d {1:00} h {2:00} m {3:00} s" -f $_.Days, $_.Hours, $_.Minutes, $_.Seconds
    }
}

function Out-Object {
    param(
        [System.Collections.Hashtable[]] $hashData
    )
    $order = @()
    $result = @{ }
    $hashData | ForEach-Object {
        $order += ($_.Keys -as [Array])[0]
        $result += $_
    }
    New-Object PSObject -Property $result | Select-Object $order
}

function Get-Uptime {
    param(
        $computerName
    )

    $params = @{
        "Class"     = "Win32_OperatingSystem"
        "Namespace" = "root\CIMV2"
    }
    try {
        $wmiOS = Get-WmiObject @params -ErrorAction Stop
    }
    catch {
        Write-Error -Exception (New-Object $_.Exception.GetType().FullName `
            ("Cannot connect to the computer '$computerName' due to the following error: '$($_.Exception.Message)'",
                $_.Exception))
        return
    }
    $lastBootTime = [Management.ManagementDateTimeConverter]::ToDateTime($wmiOS.LastBootUpTime)
    $result = Out-Object `
    @{"LastBootTime" = $lastBootTime.ToUniversalTime().toString("r") },
    @{"Uptime" = (Get-Date) - $lastBootTime | Format-TimeSpan }

    return $result
}

function Get-PSVersion {
    if (test-path variable:psversiontable) { $psversiontable.psversion } else { [version]"1.0.0.0" }
}

function Get-Mini-Info() {
    Param( 
        [Parameter( 
            Mandatory = $true, 
            Position = 0, 
            ValueFromPipeline = $true, 
            ValueFromPipelineByPropertyName = $true)] 
        [string]$Token
    ) 

    #region Inventory Classes
    $json = " { `"id`": `"" + (Get-WmiObject Win32_ComputerSystemProduct uuid).uuid + "`","
    $json += "`n `"Token`": `"" + $Token + "`","
    $json += "`n `"Hostname`": `"" + $env:COMPUTERNAME + "`","
    $json += "`n `"SnapshotDate`": `"" + $(Get-Date -format u) + "`","
    $json += "`n `"PsVersion`": `"" + $(Get-PSVersion) + "`""
    $json += "`n } "

    return $json
}

function Get-Info() {
    Param( 
        [Parameter( 
            Mandatory = $true, 
            Position = 0, 
            ValueFromPipeline = $true, 
            ValueFromPipelineByPropertyName = $true)] 
        [string]$Token
    ) 

    #region Inventory Classes
    $json = " { `"id`": `"" + (Get-WmiObject Win32_ComputerSystemProduct uuid).uuid + "`","
    $json += "`n `"Token`": `"" + $Token + "`","
    $json += "`n `"Hostname`": `"" + $env:COMPUTERNAME + "`","
    $json += "`n `"SnapshotDate`": `"" + $(Get-Date -format u) + "`""

    $json += WMIInv -name "useraccounts" -query "Select * FROM Win32_UserAccount"
    $json += WMIInv -name "Battery" -query "Select * FROM Win32_Battery" "root\cimv2"
    $json += WMIInv -name "BIOS" -query "Select * FROM Win32_Bios" "root\cimv2"
    $json += WMIInv -name "CDROMDrive" -query "Select * FROM Win32_CDROMDrive" "root\cimv2"
    $json += WMIInv -name "ComputerSystem" -query "Select * FROM Win32_ComputerSystem" "root\cimv2"
    $json += WMIInv -name "ComputerSystemProduct" -query "Select * FROM Win32_ComputerSystemProduct" "root\cimv2"
    $json += WMIInv -name "DiskDrive" -query "Select * FROM Win32_DiskDrive" "root\cimv2"
    $json += WMIInv -name "DiskPartition" -query "Select * FROM Win32_DiskPartition" "root\cimv2"
    $json += WMIInv -name "Environment" -query "Select * FROM Win32_Environment" "root\cimv2"
    $json += WMIInv -name "IDEController" -query "Select * FROM Win32_IDEController" "root\cimv2"
    $json += WMIInv -name "NetworkAdapter" -query "Select * FROM Win32_NetworkAdapter" "root\cimv2"
    $json += WMIInv -name "NetworkAdapterConfiguration" -query "Select * FROM Win32_NetworkAdapterConfiguration" "root\cimv2"
    #$json += WMIInv "NetrkClient" "Select * FROM Win32_NetworkClient" "root\cimv2"
    #$json += WMIInv "MotherboardDevice" "Select * FROM Win32_MotherboardDevice" "root\cimv2"
    $json += WMIInv -name "OperatingSystem" -query "Select * FROM Win32_OperatingSystem" "root\cimv2"

    $json += WMIInv -name "PhysicalMemory" -query "Select * FROM Win32_PhysicalMemory" "root\cimv2"
    $json += WMIInv -name "PnpEntity" -query "Select * FROM Win32_PnpEntity" "root\cimv2"
    $json += WMIInv -name "QuickFixEngineering" -query "Select * FROM Win32_QuickFixEngineering" "root\cimv2"
    $json += WMIInv -name "Share" -query "Select * FROM Win32_Share" "root\cimv2"
    $json += WMIInv -name "SoundDevice" -query "Select * FROM Win32_SoundDevice" "root\cimv2"
    $json += WMIInv -name "Service" -query "Select * FROM Win32_Service" "root\cimv2"
    $json += WMIInv -name "SystemEnclosure" -query "Select * FROM Win32_SystemEnclosure" "root\cimv2"
    $json += WMIInv -name "VideoController" -query "Select * FROM Win32_VideoController" "root\cimv2"
    $json += WMIInv -name "Volume" -query "Select * FROM Win32_Volume" "root\cimv2"
    
    
    $json += ",`n `"LoggedUsers`":" 

    $json += registry_values "hklm:\software\microsoft\windows nt\currentversion\profilelist" "profileimagepath" | ConvertTo-Json

    $json += ",`n `"Processes`":" 
    $json += Get-Process | Select-Object ProcessName, Name, FileName, FileVersion, Path, Company, Product, Description, ProductVersion | ConvertTo-Json 

    $json += ",`n `"ProcessCommandLine`":" 
    $json += Get-CimInstance Win32_Process | Select-Object -Property Name, ProcessName, Path, CommandLine | where-object { $null -ne $_.CommandLine } | ConvertTo-Json

    $json += ",`n `"Uptime`":" 

    $json += Get-Uptime | ConvertTo-Json

    $json += ",`n `"PublicIP`":" 

    $json += GetPublicIP | ConvertTo-Json

    $json += ",`n `"Software`":" 
    #$SW = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* -ea SilentlyContinue | ? { $_.DisplayName -ne $null -and $_.SystemComponent -ne 0x1 -and $_.ParentDisplayName -eq $null } | Select DisplayName, DisplayVersion, Publisher, InstallDate, HelpLink, UninstallString
    $SW = Get-RegistryUninstallKey | Where-Object { $null -ne $_.DisplayName -and $_.SystemComponent -ne 0x1 -and $null -eq $_.ParentDisplayName } | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate, HelpLink, UninstallString
    #$SW += Get-ItemProperty HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* -ea SilentlyContinue | ? { $_.DisplayName -ne $null -and $_.SystemComponent -ne 0x1 -and $_.ParentDisplayName -eq $null } | Select DisplayName, DisplayVersion, Publisher, InstallDate, HelpLink, UninstallString
    $json += $SW | ConvertTo-Json

    $json += ",`n `"Windows Updates`":"

    $objSearcher = (New-Object -ComObject Microsoft.Update.Session).CreateUpdateSearcher();
    $objResults = $objSearcher.Search('IsHidden=0');
    $upd += $objResults.Updates | Select-Object -Property @{n = 'IsInstalled'; e = { $_.IsInstalled } }, @{n = 'KB'; e = { $_.KBArticleIDs } }, @{n = 'Bulletin'; e = { $_.SecurityBulletinIDs.Item(0) } }, @{n = 'Title'; e = { $_.Title } }, @{n = 'UpdateID'; e = { $_.Identity.UpdateID } }, @{n = 'Revision'; e = { $_.Identity.RevisionNumber } }, @{n = 'LastChange'; e = { $_.LastDeploymentChangeTime } }
    if ($upd)
    { $json += $upd | ConvertTo-Json }
    else { $json += "null" }

    $json += "`n } "

    return $json

}

