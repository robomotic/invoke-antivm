function Get_Environment_Variables() {
	<#
	Foreach ($item in Get-ChildItem -Path Env:\)
	{
		Write-Host $item.Name
	}
	#>

	Write-Host "ALLUSERSPROFILE = $env:ALLUSERSPROFILE"
	Write-Host "APPDATA = $env:APPDATA"
	Write-Host "CommonProgramFiles = $env:CommonProgramFiles"
	Write-Host "CommonProgramFiles(x86) = $env:CommonProgramFiles(x86)"
	Write-Host "COMPUTERNAME = $env:COMPUTERNAME"
	Write-Host "ComSpec = $env:ComSpec"
	Write-Host "HOMEDRIVE = $env:HOMEDRIVe"
	Write-Host "HOMEPATH = $env:HOMEPATH"
	Write-Host "LOCALAPPDATA = $env:LOCALAPPDATA"
	Write-Host "LOGONSERVER = $env:LOGONSERVER"
	Write-Host "NUMBER_OF_PROCESSORS = $env:NUMBER_OF_PROCESSORS"
	Write-Host "OS = $env:OS"
	Write-Host "Path = $env:Path"
	Write-Host "PROCESSOR_ARCHITECTURE = $env:PROCESSOR_ARCHITECTURE"
	Write-Host "PROCESSOR_IDENTIFIER = $env:PROCESSOR_IDENTIFIER"
	Write-Host "PROCESSOR_LEVEL = $env:PROCESSOR_LEVEL"
	Write-Host "PROCESSOR_REVISION = $env:PROCESSOR_REVISION"
	Write-Host "ProgramFiles = $env:ProgramFiles"
	Write-Host "ProgramFiles(x86) = $env:ProgramFiles(x86)"
	Write-Host "PROMPT = $env:PROMPT"
	Write-Host "PUBLIC = $env:PUBLIC"
	Write-Host "SystemDrive = $env:SystemDrive"
	Write-Host "SystemRoot = $env:SystemRoot"
	Write-Host "TEMP = $env:TEMP"
	Write-Host "TMP = $env:TMP"
	Write-Host "USERDOMAIN = $env:USERDOMAIN"
	Write-Host "USERDOMAIN_ROAMINGPROFILE = $env:USERDOMAIN_ROAMINGPROFILE"
	Write-Host "USERNAME = $env:USERNAME"
	Write-Host "USERPROFILE = $env:USERPROFILE"
	Write-Host "windir = $env:windir"

}

function Get_Files() {
	Write-Host "File List"
	Write-Host "========="
	$folders = @(".")
	$folders += $home + "\Desktop"
	$folders += $home + "\Documents"
	$folders += $home + "\Downloads"
	$folders += $home + "\Favorites"
	$folders += $home + "\Music"
	$folders += $home + "\Pictures"
	$folders += $home + "\Videos"

	$folders += $home + "\My Documents"
	$folders += $home + "\My Music"
	$folders += $home + "\My Pictures"
	$folders += $home + "\My Videos"

	$ErrorActionPreference= 'silentlycontinue'
	for ($i=0; $i -lt $folders.length; $i++) {
			Get-ChildItem -Recurse -Path $folders[$i]
	}
	$ErrorActionPreference= 'Continue'
}

function Get_Installed_Programs_Registry(){
	Write-Host "Installed programs from Registry"
	Write-Host "================================"
	$keys = @()
	$keys += "HKLM:\Software"
	$keys += "HKLM:\Software\Wow6432Node"
	$keys += "HKCU:\Software"
	$keys += "HKCU:\Software\Wow6432Node"
	Foreach ($k in $keys) {
		Get-ChildItem $k | Select-Object -Property Name
	}
}
function Get_Procs() {
	$proc = Get-WMIObject -Query "SELECT * FROM Win32_Process" | Select-Object -Property Caption, Description, Name, ProcessName, CommandLine, ExecutablePath, Path
	$proc
}

function Get_Wallpaper() {
	Get-ItemProperty -path "HKCU:\Control Panel\Desktop" -name "WallPaper" | Select-Object -Property WallPaper
}

function Get_WMI_Data() {
	$hw = Get-ItemProperty -Path "HKLM:\Hardware\Description\System\BIOS"

	if (!$hw)
	{
		Get-ItemProperty -Path "HKLM:\Hardware\Description\System" | Select-Object -Property SystemBIOSVersion, VideoBiosVersion #| Format-List
	}
	Write-Host "HKLM Bios"
	$hw

	$wmi = Get-WMIObject -Query "SELECT * FROM Win32_BIOS" | Select-Object -Property Name,
		Description, Version, BIOSVersion, Manufacturer, PrimaryBIOS, SerialNumber
	Write-Host "Win32_BIOS"
	$wmi

	$wmi = Get-WMIObject -Query "SELECT * FROM Win32_ComputerSystem" |
		Select-Object -Property PSComputerName, Name, Caption, Domain, Manufacturer, Model, OEMStringArray,
		PrimaryOwnerContact, PrimaryOwnerName, SystemFamily, SystemSKUNumber, SystemType, SystemStartupOptions,
		TotalPhysicalMemory, UserName
	Write-Host "Win32_ComputerSystem"
	$wmi

	$wmi = Get-WMIObject -Query "SELECT * FROM Win32_ComputerSystemProduct" |
		Select-Object -Property IdentifyingNumber, Name, Version, Caption, Description,
		SKUNumber, UUID, Vendor, __PATH, __RELPATH, Path
	Write-Host "Win32_ComputerSystemProduct"
	$wmi

	$wmi = Get-WMIObject -Query "SELECT * FROM Win32_DeviceBus" |
	   Select-Object -Property Antecedent, Dependent, __PATH, __RELPATH #| Format-List
	Write-Host "Win32_DeviceBus"
	$wmi

	$wmi = Get-WMIObject -Query "SELECT * FROM Win32_DiskDrive" |
	   Select-Object -Property Caption, Model, Name, PNPDeviceID, SerialNumber
    Write-Host "Win32_DiskDrive"
	$wmi

	$wmi = Get-WMIObject -Query "SELECT * FROM Win32_DisplayConfiguration" |
	   Select-Object -Property __RELPATH, __PATH, Caption, Description, DeviceName,
	   SettingID, Path
	Write-Host "Win32_DisplayConfiguration"
	$wmi

	$wmi = Get-WMIObject -Query "SELECT * FROM Win32_DisplayControllerConfiguration" |
	   Select-Object -Property __RELPATH, __PATH, Caption, Description, Name,
	   SettingID, Path
	Write-Host "Win32_DisplayControllerConfiguration"
	$wmi

	$wmi = Get-WMIObject -Query "SELECT * FROM Win32_NetworkAdapter" |
	   Select-Object -Property Name, Caption, Description, Manufacturer, ProductName,
	   ServiceName #| Format-List
	Write-Host "Win32_NetworkAdapter"
	$wmi
}

function Hyper_V() {
    Get-ChildItem HKLM:\SOFTWARE\Microsoft | Select-Object -Property Name
	Get-ItemProperty HKLM:\HARDWARE\DESCRIPTION\System -Name SystemBiosVersion  | Select-Object -Property SystemBiosVersion
	Get-ChildItem HKLM:\HARDWARE\ACPI\FADT | Select-Object -Property Name
	Get-ChildItem HKLM:\HARDWARE\ACPI\RSDT | Select-Object -Property Name

}

Hyper_V
#Get_Environment_Variables
#Get_Wallpaper
#Get_WMI_Data	#to be continued
#Get_Procs
#Get_Files
#Get_Installed_Programs_Registry
