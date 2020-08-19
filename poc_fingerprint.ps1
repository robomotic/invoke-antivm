function Get_BIOS_Registry() {
	$output = '{"BIOS Registry":'
	$output += '['

	try {
		# Win10
		try {
			$props = @("BiosMajorRelease", "BiosMinorRelease", "ECFirmwareMajorRelease", "ECFirmwareMinorRelease", "BaseBoardManufacturer", "BaseBoardProduct", "BaseBoardVersion", "BIOSReleaseDate", "BIOSVendor", "BIOSVersion", "SystemFamily", "SystemManufacturer", "SystemProductName", "SystemSKU", "SystemVersion")
			$obj = Get-ItemProperty -Path "HKLM:\\Hardware\\Description\\System\\BIOS" | Select-Object -Property $props
		}
		catch {
			$ErrorMessage = $_.Exception.Message
			$output += '{"BIOS":"' + $ErrorMessage + '"}'
		}
		if (!$obj) {
			try {
				$props = @("Identifier", "SystemBIOSDate", "SystemBIOSVersion", "VideoBIOSVersion")
				$obj = Get-ItemProperty -Path "HKLM:\\Hardware\\Description\\System" | Select-Object -Property $props
			}
			catch {
				$ErrorMessage = $_.Exception.Message
				$output += '{"BIOS":"' + $ErrorMessage + '"}'
			}
		}
		if ($obj) {
			ForEach ($prop in $props) {
				$output += '{"' + $prop + '":"' + $obj.$prop + '"},'
			}
			# remove trailing ',' character
			$output = $output -replace ".$"
		}
	}
	catch {
		$ErrorMessage = $_.Exception.Message
		$output += '{"BIOS":"No more attempts"}'
	}
	$output += ']'
	$output += '}'

	return $output
}

function Get_Environment_Variables() {
	$output = '{"Environment Variables":'
	$output += '['

	<#
	Foreach ($item in Get-ChildItem -Path Env:\)
	{
		Write-Host $item.Name
	}
	#>

	$output += '{"ALLUSERSPROFILE":' + '"' + $env:ALLUSERSPROFILE + '"},'
	$output += '{"APPDATA":' + '"' + $env:APPDATA + '"},'
	$output += '{"CommonProgramFiles":' + '"' + $env:CommonProgramFiles + '"},'
	$output += '{"CommonProgramFiles(x86)":' + '"' + ${env:CommonProgramFiles(x86)} + '"},'
	$output += '{"COMPUTERNAME":' + '"' + $env:COMPUTERNAME + '"},'
	$output += '{"ComSpec":' + '"' + $env:ComSpec + '"},'
	$output += '{"HOMEDRIVE":' + '"' + $env:HOMEDRIVe + '"},'
	$output += '{"HOMEPATH":' + '"' + $env:HOMEPATH + '"},'
	$output += '{"LOCALAPPDATA":' + '"' + $env:LOCALAPPDATA + '"},'
	$output += '{"LOGONSERVER":' + '"' + $env:LOGONSERVER + '"},'
	$output += '{"NUMBER_OF_PROCESSORS":' + '"' + $env:NUMBER_OF_PROCESSORS + '"},'
	$output += '{"OS":' + '"' + $env:OS + '"},'
	$output += '{"Path":' + '"' + $env:Path + '"},'
	$output += '{"PROCESSOR_ARCHITECTURE":' + '"' + $env:PROCESSOR_ARCHITECTURE + '"},'
	$output += '{"PROCESSOR_IDENTIFIER":' + '"' + $env:PROCESSOR_IDENTIFIER + '"},'
	$output += '{"PROCESSOR_LEVEL":' + '"' + $env:PROCESSOR_LEVEL + '"},'
	$output += '{"PROCESSOR_REVISION":' + '"' + $env:PROCESSOR_REVISION + '"},'
	$output += '{"ProgramFiles":' + '"' + $env:ProgramFiles + '"},'
	$output += '{"ProgramFiles(x86)":' + '"' + ${env:ProgramFiles(x86)} + '"},'
	$output += '{"PROMPT":' + '"' + $env:PROMPT + '"},'
	$output += '{"PUBLIC":' + '"' + $env:PUBLIC + '"},'
	$output += '{"SystemDrive":' + '"' + $env:SystemDrive + '"},'
	$output += '{"SystemRoot":' + '"' + $env:SystemRoot + '"},'
	$output += '{"TEMP":' + '"' + $env:TEMP + '"},'
	$output += '{"TMP":' + '"' + $env:TMP + '"},'
	$output += '{"USERDOMAIN":' + '"' + $env:USERDOMAIN + '"},'
	$output += '{"USERDOMAIN_ROAMINGPROFILE":' + '"' + $env:USERDOMAIN_ROAMINGPROFILE + '"},'
	$output += '{"USERNAME":' + '"' + $env:USERNAME + '"},'
	$output += '{"USERPROFILE":' + '"' + $env:USERPROFILE + '"},'
	$output += '{"windir":' + '"' + $env:windir + '"},'
	# remove trailing ',' character
	$output = $output -replace ".$"
	$output += ']'
	$output += '}'

	return $output
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
	$output = '{"Wallpaper":'
	$output += '['

	try {
		$obj = Get-ItemProperty -path "HKCU:\Control Panel\Desktop" -name "WallPaper" | Select-Object -Property WallPaper
		if ($obj) {
			$output += '{"Wallpaper":"' + $obj.WallPaper + '"}'
		}

		if ($obj.WallPaper) {
			try {
				#$ = Get-FileHash -Path $obj.WallPaper -Algorithm SHA256
				try {
					$hash = $(CertUtil -hashfile $obj.WallPaper SHA256)[1] -replace " ",""
				}
				catch {
					$ErrorMessage = $_.Exception.Message
					$output += ',{"Wallpaper CertUtil SHA256":"' + $ErrorMessage + '"}'
				}
				if (!$hash) {
					try {
						$hash = $(md5sum $obj.WallPaper)
					}
					catch {
						$ErrorMessage = $_.Exception.Message
						$output += ',{"Wallpaper MD5Sum":"' + $ErrorMessage + '"}'
					}
				}
				if ($hash) {
					$output += ',{"Wallpaper Hash":"' + $hash + '"}'
				}
			}
			catch {
				$ErrorMessage = $_.Exception.Message
				$output += ',{"Wallpaper Hash":"No more attempts"}'
			}
		}
	}
	catch {
		$ErrorMessage = $_.Exception.Message
		$output += '{"Wallpaper":"' + $ErrorMessage + '"}'
	}
	$output += ']'
	$output += '}'

	return $output
}

function Get_WMI_Data() {
	$output = '{"WMI Data":'
	$output += '['

	$props = @("Name", "Description", "Version", "BIOSVersion", "Manufacturer", "PrimaryBIOS", "SerialNumber")
	$class = "Win32_Bios"
	$output += WMI_Query $class $props

	$output += ','
	$props = @("PSComputerName", "Name", "Caption", "Domain", "Manufacturer", "Model", "OEMStringArray",
	"PrimaryOwnerContact", "PrimaryOwnerName", "SystemFamily", "SystemSKUNumber", "SystemType", "SystemStartupOptions",
	"TotalPhysicalMemory", "UserName")
	$class = "Win32_ComputerSystem"
	$output += WMI_Query $class $props

	$output += ','
	#$props = @("IdentifyingNumber", "Name", "Version", "Caption", "Description", "SKUNumber", "UUID", "Vendor", "__PATH", "__RELPATH", "Path")
	$props = @("IdentifyingNumber", "Name", "Version", "Caption", "Description", "SKUNumber", "UUID", "Vendor")
	$class = "Win32_ComputerSystemProduct"
	$output += WMI_Query $class $props

	<#
	$output += ','
	$props = @("Antecedent", "Dependent", "__PATH", "__RELPATH")
	$class = "Win32_DeviceBus"
	$output += WMI_Query $class $props

	$output += ','
	$props = @("")
	$class = ""
	$output += WMI_Query $class $props


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
	#>
	$output += ']'
	$output += '}'

	return $output
}

function Hyper_V() {
	$output = '{"hyperv":'
	$output += '['

	try {
	    $obj = Get-ChildItem HKLM:\SOFTWARE\Microsoft | Select-Object -Property Name
		if ($obj) {
			For ($i=0; $i -lt $obj.Length; $i++) {
				$output += '{"Key_' + $i + '":"' + $obj[$i].Name + '"},'
			}
			# remove trailing ',' character
			$output = $output -replace ".$"
		}
	}
	catch {
		$ErrorMessage = $_.Exception.Message
		$output += '{"HKLM\SOFTWARE\Microsoft":"' + $ErrorMessage + '"}'
	}

	try {
		$obj = Get-ItemProperty HKLM:\HARDWARE\DESCRIPTION\System -Name SystemBiosVersion | Select-Object -Property SystemBiosVersion
		if ($obj) {
			$output += ',{"BIOS Version":"' + $obj.SystemBiosVersion + '"}'
		}
	}
	catch {
		$ErrorMessage = $_.Exception.Message
		$output += ',{"BIOS Version":"' + $ErrorMessage + '"}'
	}

	try {
		$obj = Get-ChildItem HKLM:\HARDWARE\ACPI\FADT | Select-Object -Property Name
		if ($obj) {
			$output += ',{"FADT":"' + $obj.Name + '"}'
		}
	}
	catch {
	}

	try {
		$obj = Get-ChildItem HKLM:\HARDWARE\ACPI\RSDT | Select-Object -Property Name
		if ($obj) {
			$output += ',{"RSDT":"' + $obj.Name + '"}'
		}
	}
	catch {}
	$output += ']'
	$output += '}'

	return $output
}

function WMI_Query() {
	Param($class, $props)

	$output = ''
	try {
		$wmi = Get-WMIObject -Query "SELECT * FROM $class" | Select-Object -Property $props
		if ($wmi) {
			ForEach ($prop in $props) {
				#$prop -replace '"', "'"
				$output += '{"' + $class + '.' + $prop + '":"' + $wmi.$prop + '"},'
			}
		}
		# remove trailing ',' character
		$output = $output -replace ".$"
	}
	catch {
		$ErrorMessage = $_.Exception.Message
		$output += '{"$class":"' + $ErrorMessage + '"}'
	}
	return $output
}

$ErrorActionPreference = 'stop'
$out = '['

$out += Hyper_V
$out += ','
$out += Get_Environment_Variables
$out += ','
$out += Get_Wallpaper
$out += ','
$out += Get_BIOS_Registry
$out += ','
$out += Get_WMI_Data	#to be continued
#Get_Procs
#Get_Files
#Get_Installed_Programs_Registry
$out += ']'
$out = $out -replace '\\', '\\'
Write-Host $out
# OS VERSION
