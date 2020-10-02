function checkBiosRegistry()
{
	$output = @()

	$key = "HKLM:\Hardware\Description\System\BIOS"
	$objects = Registry_Values_Query $key
	ForEach ($obj in $objects)
	{
		$common = Common_String $obj
		if ($common -or $obj -like "*virtual*")
		{
			$obj | Add-Member -MemberType NoteProperty -Name "status" -value 1
			$obj | Add-Member -MemberType NoteProperty -Name "class" -value "HyperV"
			$obj | Add-Member -MemberType NoteProperty -Name "property" -value "BIOS"
			$obj | Add-Member -MemberType NoteProperty -Name "property_value" -value $obj
			$output += $obj
		}
	}

	$key = "HKLM:\Hardware\Description\System"
	$objects = Registry_Values_Query $key
	ForEach ($obj in $objects)
	{
		$common = Common_String $obj
		if ($common -or $obj -like "*virtual*")
		{
			$obj | Add-Member -MemberType NoteProperty -Name "status" -value 1
			$obj | Add-Member -MemberType NoteProperty -Name "class" -value "HyperV"
			$obj | Add-Member -MemberType NoteProperty -Name "property" -value "BIOS"
			$obj | Add-Member -MemberType NoteProperty -Name "property_value" -value $obj
			$output += $obj
		}
	}

	return $output
}

function checkBiosWmi()
{

	$props = @("Name", "Description", "Version", "BIOSVersion", "Manufacturer", "PrimaryBIOS", "SerialNumber")
	$class = "Win32_BIOS"
	$objects = WMI_Query $class $props
	$output = @()
	ForEach ($obj in $objects)
	{
		$common = Common_String $obj.property_value
		if ($common)
		{
			$obj | Add-Member -MemberType NoteProperty -Name "status" -value 1
			$obj | Add-Member -MemberType NoteProperty -Name "class" -value $class
			$output += $obj
		}
	}
	return $output
}

function checkDiskDrive()
{

	$props = @("FirmwareRevision", "InterfaceType", "Manufacturer", "Model", "Name", "Partitions", "SerialNumber", "Size")
	$class = "Win32_DiskDrive"
	$objects = WMI_Query $class $props
	$output = @()
	ForEach ($obj in $objects)
	{
		$common = Common_String $obj.property_value
		if ($common -or $obj.property_value -like "*virtual*")
		{
			$obj | Add-Member -MemberType NoteProperty -Name "status" -value 1
			$obj | Add-Member -MemberType NoteProperty -Name "class" -value $class
			$output += $obj
		}
		if ($obj.property -like "*serialnumber*")
		{
			if ($obj.property_value -eq "0000" -or $obj.property_value -eq "0001")
			{
				$obj | Add-Member -MemberType NoteProperty -Name "status" -value 2
				$obj | Add-Member -MemberType NoteProperty -Name "class" -value $class
				$output += $obj
			}
		}
	}
	return $output
}

function checkDisplayConfiguration()
{
	$props = @("Caption", "Description", "DeviceName", "SettingID", "Path")
	$class = "Win32_DisplayConfiguration"
	$objects = WMI_Query $class $props
	$output = @()
	ForEach ($obj in $objects)
	{
		$common = Common_String $obj.property_value
		if ($common)
		{
			$obj | Add-Member -MemberType NoteProperty -Name "status" -value 1
			$obj | Add-Member -MemberType NoteProperty -Name "class" -value $class
			$output += $obj
		}
	}
	return $output
}

function checkDisplayControllerConfiguration()
{
	$props = @("Caption", "Description", "Name", "SettingID", "Path")
	$class = "Win32_DisplayControllerConfiguration"
	$objects = WMI_Query $class $props
	$output = @()
	ForEach ($obj in $objects)
	{
		$common = Common_String $obj.property_value
		if ($common)
		{
			$obj | Add-Member -MemberType NoteProperty -Name "status" -value 1
			$obj | Add-Member -MemberType NoteProperty -Name "class" -value $class
			$output += $obj
		}
	}
	return $output
}

function checkHyperV()
{
	$output = @()

	$key = "HKLM:\HARDWARE\ACPI\FADT"
	$objects = Registry_Key_Query $key
	ForEach ($obj in $objects)
	{
		$common = Common_String $obj
		if ($common)
		{
			$obj | Add-Member -MemberType NoteProperty -Name "status" -value 1
			$obj | Add-Member -MemberType NoteProperty -Name "class" -value "HyperV"
			$obj | Add-Member -MemberType NoteProperty -Name "property" -value $key
			$obj | Add-Member -MemberType NoteProperty -Name "property_value" -value $obj
			$output += $obj
		}
	}

	$key = "HKLM:\HARDWARE\ACPI\RSDT"
	$objects = Registry_Key_Query $key
	ForEach ($obj in $objects)
	{
		$common = Common_String $obj
		if ($common)
		{
			$obj | Add-Member -MemberType NoteProperty -Name "status" -value 1
			$obj | Add-Member -MemberType NoteProperty -Name "class" -value "HyperV"
			$obj | Add-Member -MemberType NoteProperty -Name "property" -value $key
			$obj | Add-Member -MemberType NoteProperty -Name "property_value" -value $obj
			$output += $obj
		}
	}

	return $output
}

function checkIdeChannels()
{
	$props = @("Name", "Description", "Manufacturer")
	$class = "Win32_IDEController"
	$objects = WMI_Query $class $props
	$output = @()

	$channels = 0
	ForEach ($obj in $objects)
	{
		if ($obj.property -like "*Name*" -and $obj.property_value -like "*ATA Channel*")
		{
			$channels += 1
		}
	}

	if ($channels -gt 20)
	{
		$obj = New-Object -TypeName psobject
		$obj | Add-Member -MemberType NoteProperty -Name "status" -value 2
		$obj | Add-Member -MemberType NoteProperty -Name "class" -value "IDE Channels"
		$obj | Add-Member -MemberType NoteProperty -Name "property" -value "Count"
		$obj | Add-Member -MemberType NoteProperty -Name "property_value" -value $channels
		$output += $obj
	}
	return $output


}

function checkOnBoardDevice()
{
	$props = @("Description", "DeviceType", "Name", "PartNumber", "SerialNumber")
	$class = "Win32_OnBoardDevice"
	$objects = WMI_Query $class $props
	$output = @()
	if (!$objects)
	{
		$obj = New-Object -TypeName psobject
		$obj | Add-Member -MemberType NoteProperty -Name "status" -value 2
		$obj | Add-Member -MemberType NoteProperty -Name "class" -value $class
		$obj | Add-Member -MemberType NoteProperty -Name "property" -value "Status"
		$obj | Add-Member -MemberType NoteProperty -Name "property_value" -value "No onboard devices found"
		$output += $obj
	}
	return $output

}

function checkPhysicalMemory()
{
	$props = @("BankLabel", "Capacity", "Caption", "Description", "DeviceLocator", "Manufacturer", "PartNumber", "SerialNumber")
	$class = "Win32_PhysicalMemory"
	$objects = WMI_Query $class $props
	$output = @()
	if (!$objects)
	{
		$obj = New-Object -TypeName psobject
		$obj | Add-Member -MemberType NoteProperty -Name "status" -value 2
		$obj | Add-Member -MemberType NoteProperty -Name "class" -value $class
		$obj | Add-Member -MemberType NoteProperty -Name "property" -value "Status"
		$obj | Add-Member -MemberType NoteProperty -Name "property_value" -value "No hardware RAM found"
		$output += $obj
	}
	return $output

}

function checkPnP()
{

	$props = @("Manufacturer", "Name", "Description", "Service", "PNPClass", "PNPDeviceID")
	$class = "Win32_PnpEntity"
	$objects = WMI_Query $class $props
	$output = @()
	ForEach ($obj in $objects)
	{
		$common = Common_String $obj.property_value
		if ($common)
		{
			$obj | Add-Member -MemberType NoteProperty -Name "status" -value 1
			$obj | Add-Member -MemberType NoteProperty -Name "class" -value $class
			$output += $obj
		}
		if ($obj.property_value -like '*Red Hat*')
		{
			$obj | Add-Member -MemberType NoteProperty -Name "status" -value 2
			$obj | Add-Member -MemberType NoteProperty -Name "class" -value $class
			$output += $obj
		}
		if ($obj.property_value -like '*A3E64E55_pr*')	# found on anyrun
		{
			$obj | Add-Member -MemberType NoteProperty -Name "status" -value 2
			$obj | Add-Member -MemberType NoteProperty -Name "class" -value $class
			$output += $obj
		}
	}
	return $output
}

function checkSoundDevice()
{
	$props = @("Description", "Manufacturer", "ProductName")
	$class = "Win32_SoundDevice"
	$objects = WMI_Query $class $props
	$output = @()
	if (!$objects)
	{
		$obj = New-Object -TypeName psobject
		$obj | Add-Member -MemberType NoteProperty -Name "status" -value 2
		$obj | Add-Member -MemberType NoteProperty -Name "class" -value $class
		$obj | Add-Member -MemberType NoteProperty -Name "property" -value "Status"
		$obj | Add-Member -MemberType NoteProperty -Name "property_value" -value "None"
		$output += $obj
	}
	return $output

}

function checkSystemEnclosure()
{

	$props = @("Description", "Manufacturer", "SecurityStatus", "SerialNumber")
	$class = "Win32_SystemEnclosure"
	$objects = WMI_Query $class $props
	$output = @()
	ForEach ($obj in $objects)
	{
		$common = Common_String $obj.property_value
		if ($common)
		{
			$obj | Add-Member -MemberType NoteProperty -Name "status" -value 1
			$obj | Add-Member -MemberType NoteProperty -Name "class" -value $class
			$output += $obj
		}
	}
	return $output
}

function checkVideoController()
{

	$props = @("AdapterCompatibility", "AdapterRAM", "Caption", "Description", "Name", "VideoProcessor")
	$class = "Win32_VideoController"
	$objects = WMI_Query $class $props
	$output = @()
	ForEach ($obj in $objects)
	{
		$common = Common_String $obj.property_value
		if ($common)
		{
			$obj | Add-Member -MemberType NoteProperty -Name "status" -value 1
			$obj | Add-Member -MemberType NoteProperty -Name "class" -value $class
			$output += $obj
		}
	}
	if (!$objects)
	{
		$obj = New-Object -TypeName psobject
		$obj | Add-Member -MemberType NoteProperty -Name "status" -value 2
		$obj | Add-Member -MemberType NoteProperty -Name "class" -value $class
		$obj | Add-Member -MemberType NoteProperty -Name "property" -value "Status"
		$obj | Add-Member -MemberType NoteProperty -Name "property_value" -value "No video controller"
		$output += $obj
	}

	return $output
}
