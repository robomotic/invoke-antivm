

function WMIInv ([string]$Name, [string]$query, [string]$namespace = "root\cimv2")
{
<#
.SYNOPSIS

Format the WMI call into JSON
Author:  Paolo Di Prodi (@robomotic)

From: https://github.com/rzander/DocumentDB-Inventory/blob/master/Inventory%20Agents/Windows-Devices/Create-Inventory.ps1
   
#>
    $jsonout = ",`n `"$($Name)`":" 
    $val += Get-WmiObject -Namespace $namespace -Query $query -ea SilentlyContinue| select * -ExcludeProperty Scope,Options,ClassPath,Properties,SystemProperties,Qualifiers,Site,Container,PSComputerName, Path, __* | Sort | ConvertTo-Json
    if($val -eq $null) { $val = " null" } 
    $jsonout += $val
    return $jsonout
}

function GetPublicIP(){
    $json = Invoke-RestMethod http://ipinfo.io/json

    $obj = New-Object psobject
    Add-Member -InputObject $obj -MemberType NoteProperty -Name ipv4 -Value $json.ip
    Add-Member -InputObject $obj -MemberType NoteProperty -Name city -Value $json.city
    Add-Member -InputObject $obj -MemberType NoteProperty -Name region -Value $json.region
    Add-Member -InputObject $obj -MemberType NoteProperty -Name country -Value $json.country
    Add-Member -InputObject $obj -MemberType NoteProperty -Name location -Value $json.loc
    return $obj
}

function registry_values($regkey, $regvalue,$child) 
{ 
    if ($child -eq "no"){$key = get-item $regkey} 
    else{$key = get-childitem $regkey} 
    $key | 
    ForEach-Object { 
        $values = Get-ItemProperty $_.PSPath 
        ForEach ($value in $_.Property) 
        { 
            if ($regvalue -eq "all") {$values.$value} 
            elseif ($regvalue -eq "allname"){$value} 
            else {$values.$regvalue;break} 
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
$keys = Get-ChildItem HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall | 
    foreach {
        $obj = New-Object psobject
        Add-Member -InputObject $obj -MemberType NoteProperty -Name GUID -Value $_.pschildname
        Add-Member -InputObject $obj -MemberType NoteProperty -Name DisplayName -Value $_.GetValue("DisplayName")
        Add-Member -InputObject $obj -MemberType NoteProperty -Name DisplayVersion -Value $_.GetValue("DisplayVersion")
        if ($Wow6432Node)
        {Add-Member -InputObject $obj -MemberType NoteProperty -Name Wow6432Node? -Value "No"}
        $results += $obj
        }
 
if ($Wow6432Node) {
$keys = Get-ChildItem HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall | 
    foreach {
        $obj = New-Object psobject
        Add-Member -InputObject $obj -MemberType NoteProperty -Name GUID -Value $_.pschildname
        Add-Member -InputObject $obj -MemberType NoteProperty -Name DisplayName -Value $_.GetValue("DisplayName")
        Add-Member -InputObject $obj -MemberType NoteProperty -Name DisplayVersion -Value $_.GetValue("DisplayVersion")
        Add-Member -InputObject $obj -MemberType NoteProperty -Name Wow6432Node? -Value "Yes"
        $results += $obj
        }
    }
return $results | sort DisplayName
} 


function Format-TimeSpan {
    process {
        "{0:00} d {1:00} h {2:00} m {3:00} s" -f $_.Days,$_.Hours,$_.Minutes,$_.Seconds
    }
}

function Out-Object {
    param(
        [System.Collections.Hashtable[]] $hashData
    )
    $order = @()
    $result = @{}
    $hashData | ForEach-Object {
        $order += ($_.Keys -as [Array])[0]
        $result += $_
    }
    New-Object PSObject -Property $result | Select-Object $order
}

function Get-Uptime {
    param(
        $computerName,
        $credential
    )
    # In case pipeline input contains ComputerName property
    if ( $computerName.ComputerName ) {
        $computerName = $computerName.ComputerName
    }
    if ( (-not $computerName) -or ($computerName -eq ".") ) {
        $computerName = [Net.Dns]::GetHostName()
    }
    $params = @{
        "Class" = "Win32_OperatingSystem"
        "ComputerName" = $computerName
        "Namespace" = "root\CIMV2"
    }
    if ( $credential ) {
        # Ignore -Credential for current computer
        if ( $computerName -ne [Net.Dns]::GetHostName() ) {
        $params.Add("Credential", $credential)
        }
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
        @{"LastBootTime" = $lastBootTime.ToUniversalTime().toString("r")},
        @{"Uptime"       = (Get-Date) - $lastBootTime | Format-TimeSpan}

    return $result
}


function Generate-Info() {
    #region Inventory Classes
    $json = " { `"id`": `"" + (Get-WmiObject Win32_ComputerSystemProduct uuid).uuid + "`","
    $json += "`n `"hostname`": `"" + $env:COMPUTERNAME + "`","
    $json += "`n `"InventoryDate`": `"" + $(Get-Date -format u) + "`""

    $json += WMIInv "useraccounts" "Select * FROM Win32_UserAccount"
    $json += WMIInv "Battery" "Select * FROM Win32_Battery" "root\cimv2"
    $json += WMIInv "BIOS" "Select * FROM Win32_Bios" "root\cimv2"
    $json += WMIInv "CDROMDrive" "Select * FROM Win32_CDROMDrive" "root\cimv2"
    $json += WMIInv "ComputerSystem" "Select * FROM Win32_ComputerSystem" "root\cimv2"
    $json += WMIInv "ComputerSystemProduct" "Select * FROM Win32_ComputerSystemProduct" "root\cimv2"
    $json += WMIInv "DiskDrive" "Select * FROM Win32_DiskDrive" "root\cimv2"
    $json += WMIInv "DiskPartition" "Select * FROM Win32_DiskPartition" "root\cimv2"
    $json += WMIInv "Environment" "Select * FROM Win32_Environment" "root\cimv2"
    $json += WMIInv "IDEController" "Select * FROM Win32_IDEController" "root\cimv2"
    $json += WMIInv "NetworkAdapter" "Select * FROM Win32_NetworkAdapter" "root\cimv2"
    $json += WMIInv "NetworkAdapterConfiguration" "Select * FROM Win32_NetworkAdapterConfiguration" "root\cimv2"
    #$json += WMIInv "NetrkClient" "Select * FROM Win32_NetworkClient" "root\cimv2"
    #$json += WMIInv "MotherboardDevice" "Select * FROM Win32_MotherboardDevice" "root\cimv2"
    $json += WMIInv "OperatingSystem" "Select * FROM Win32_OperatingSystem" "root\cimv2"
    #$json += WMIInv "Process" "Select * FROM Win32_Process" "root\cimv2"
    $json += WMIInv "PhysicalMemory" "Select * FROM Win32_PhysicalMemory" "root\cimv2"
    $json += WMIInv "PnpEntity" "Select * FROM Win32_PnpEntity" "root\cimv2"
    $json += WMIInv "QuickFixEngineering" "Select * FROM Win32_QuickFixEngineering" "root\cimv2"
    $json += WMIInv "Share" "Select * FROM Win32_Share" "root\cimv2"
    $json += WMIInv "SoundDevice" "Select * FROM Win32_SoundDevice" "root\cimv2"
    $json += WMIInv "Service" "Select * FROM Win32_Service" "root\cimv2"
    $json += WMIInv "SystemEnclosure" "Select * FROM Win32_SystemEnclosure" "root\cimv2"
    $json += WMIInv "VideoController" "Select * FROM Win32_VideoController" "root\cimv2"
    $json += WMIInv "Volume" "Select * FROM Win32_Volume" "root\cimv2"
    
    


    $json += ",`n `"LoggedUsers`":" 

    $json += registry_values "hklm:\software\microsoft\windows nt\currentversion\profilelist" "profileimagepath" | ConvertTo-Json

    $json += ",`n `"Uptime`":" 

    $json += Get-Uptime | ConvertTo-Json

    $json += ",`n `"PublicIP`":" 

    $json += GetPublicIP | ConvertTo-Json

    $json += ",`n `"Software`":" 
    #$SW = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* -ea SilentlyContinue | ? { $_.DisplayName -ne $null -and $_.SystemComponent -ne 0x1 -and $_.ParentDisplayName -eq $null } | Select DisplayName, DisplayVersion, Publisher, InstallDate, HelpLink, UninstallString
    $SW = Get-RegistryUninstallKey | ? { $_.DisplayName -ne $null -and $_.SystemComponent -ne 0x1 -and $_.ParentDisplayName -eq $null } | Select DisplayName, DisplayVersion, Publisher, InstallDate, HelpLink, UninstallString
    #$SW += Get-ItemProperty HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* -ea SilentlyContinue | ? { $_.DisplayName -ne $null -and $_.SystemComponent -ne 0x1 -and $_.ParentDisplayName -eq $null } | Select DisplayName, DisplayVersion, Publisher, InstallDate, HelpLink, UninstallString
    $json += $SW | ConvertTo-Json

    $json += ",`n `"Windows Updates`":"

    $objSearcher = (New-Object -ComObject Microsoft.Update.Session).CreateUpdateSearcher();
    $objResults = $objSearcher.Search('IsHidden=0');
    $upd += $objResults.Updates | Select-Object -Property @{n='IsInstalled';e={$_.IsInstalled}},@{n='KB';e={$_.KBArticleIDs}},@{n='Bulletin';e={$_.SecurityBulletinIDs.Item(0)}},@{n='Title';e={$_.Title}},@{n='UpdateID';e={$_.Identity.UpdateID}},@{n='Revision';e={$_.Identity.RevisionNumber}},@{n='LastChange';e={$_.LastDeploymentChangeTime}}
    if($upd)
        {  $json += $upd  | ConvertTo-Json }
    else { $json += "null"}

    $json += "`n } "

    return $json

}

