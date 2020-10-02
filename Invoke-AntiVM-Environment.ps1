function checkComputerSystem()
{
	$props = @("PSComputerName", "Name", "Caption", "Domain", "Manufacturer", "Model", "OEMStringArray",
	"PrimaryOwnerContact", "PrimaryOwnerName", "SystemFamily", "SystemSKUNumber", "SystemType", "SystemStartupOptions",
	"TotalPhysicalMemory", "UserName")
	$class = "Win32_ComputerSystem"
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

function checkComputerSystemProduct()
{
	$props = @("IdentifyingNumber", "Name", "Version", "Caption", "Description", "SKUNumber", "UUID", "Vendor", "__PATH", "__RELPATH", "Path")
	$class = "Win32_ComputerSystemProduct"
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

function checkEnvironment()
{
	$output = @()

	Try
	{
		$vars = Get-ChildItem -Path Env:\ | Select-Object -Property Name, Value
		ForEach ($var in $vars) {
			if ($var.Name -eq "COMPUTERNAME")
			{
				if ($var.Value -eq 'USER-PC')
				{
					$var | Add-Member -MemberType NoteProperty -Name "status" -value 2		# seen on ANY-RUN
					$var | Add-Member -MemberType NoteProperty -Name "class" -value "Environment"
					$var | Add-Member -MemberType NoteProperty -Name "property" -value "COMPUTERNAME"
					$var | Add-Member -MemberType NoteProperty -Name "property_value" -value $var.Value
					$output += $var
				}
			}
			if ($var.Name -eq "USERDOMAIN")
			{
				if ($var.Value -eq 'USER-PC')
				{
					$var | Add-Member -MemberType NoteProperty -Name "status" -value 2		# seen on ANY-RUN
					$var | Add-Member -MemberType NoteProperty -Name "class" -value "Environment"
					$var | Add-Member -MemberType NoteProperty -Name "property" -value "USERDOMAIN"
					$var | Add-Member -MemberType NoteProperty -Name "property_value" -value $var.Value
					$output += $var
				}
			}
		}
	}

	catch
	{
		$ErrorMessage = $_.Exception.Message
		return $ErrorMessage
	}

	return $output
}

function checkFiles()
{
	$output = @()
	$folders = @()
	$folders += $home + "\Recent"
	$folders += $home + "\AppData\Roaming\Microsoft\Windows\Recent"
	$recentFiles = 0

	For ($i=0; $i -lt $folders.Length; $i++)
	{
		try
		{
			$obj = Get-ChildItem -Recurse -Force -Path $folders[$i] # Name, DirectoryName, BaseName, FullName
			For($j=0; $j -lt $obj.Length; $j++)
			{
				# avoid .lnk shortcuts, etc
				if ($obj[$j].DirectoryName)
				{
					if ($obj[$j].FullName)
					{
						$recentFiles += 1
					}
				}
			}
		}
		catch {}
	}

	if ($recentFiles -lt 20)
	{
		$var = New-Object -TypeName psobject
		$var | Add-Member -MemberType NoteProperty -Name "status" -value 2		# seen on ANY-RUN
		$var | Add-Member -MemberType NoteProperty -Name "class" -value "Files in Recent Directory"
		$var | Add-Member -MemberType NoteProperty -Name "property" -value "Count"
		$var | Add-Member -MemberType NoteProperty -Name "property_value" -value $recentFiles
		$output += $var
	}

	return $output
}

function checkFilesExplorer
{
	$output = @()

	$key = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\LastVisitedPidlMRU"
	$objects = Registry_Values_Query $key
	if ($objects.length -gt 0 -and $objects.length -lt 5)
	{
		$obj = New-Object -TypeName psobject
		$obj | Add-Member -MemberType NoteProperty -Name "status" -value 2
		$obj | Add-Member -MemberType NoteProperty -Name "class" -value "Recent Files in Explorer"
		$obj | Add-Member -MemberType NoteProperty -Name "property" -value "Count"
		$obj | Add-Member -MemberType NoteProperty -Name "property_value" -value $objects.length
		$output += $obj
	}

	return $output
}

function checkFilesOffice
{
	$output = @()
	$office = ("Word", "Excel")

	ForEach ($o in $office)
	{
		$max_count = 0
		for ($i=0; $i -le 20; $i++)
		{
			$key = "HKCU:\Software\Microsoft\Office\$i.0\$o\File MRU"
			$objects = Registry_Values_Query $key
			if ($objects.length -gt $max_count)
			{
				$max_count = $objects.length
			}
	    }

		if ($max_count -gt 0 -and $max_count -lt 10)
		{
			$obj = New-Object -TypeName psobject
			$obj | Add-Member -MemberType NoteProperty -Name "status" -value 2
			$obj | Add-Member -MemberType NoteProperty -Name "class" -value "Recent Files in Office $o"
			$obj | Add-Member -MemberType NoteProperty -Name "property" -value "Count"
			$obj | Add-Member -MemberType NoteProperty -Name "property_value" -value $max_count
			$output += $obj
		}
	}

	return $output
}

function checkWallpaper() {
	$output = @()

	try {
		$obj = Get-ItemProperty -path "HKCU:\Control Panel\Desktop" -name "WallPaper" | Select-Object -Property WallPaper
		if ($obj)
		{
			try
			{
				$hash = $(CertUtil -hashfile $obj.WallPaper SHA256)[1] -replace " ",""
			}
			catch {}
			if (!$hash)
			{
				try
				{
					$hash = $(md5sum $obj.WallPaper)
				}
				catch {}
			}
			if ($hash)
			{
				$obj | Add-Member -MemberType NoteProperty -Name "class" -value "Default SHA256 WallPaper"
				$obj | Add-Member -MemberType NoteProperty -Name "property_value" -value $obj.WallPaper
				# Default Win7
				if ($hash -eq '6ea9f8468c76aa511a5b3cfc36fb212b86e7abd377f147042d2f25572bf206a2' -or $hash -eq '1b4913688521ec480a8bfcae930d028a52e9555380f198a608dc660a64187456')
				{
					$obj | Add-Member -MemberType NoteProperty -Name "status" -value 2
					$obj | Add-Member -MemberType NoteProperty -Name "property" -value "Location"
					$output += $obj
				}
			}
		}
	}
	catch {}

	return $output
}
