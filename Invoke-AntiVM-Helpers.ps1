function Common_String()
{
	Param($string)

	if ($string -like "*vbox*" -or $string -like "*virtualbox*" -or $string -like "*vmware*" -or $string -like "*xen*" -or $string -like "*qemu*" -or $string -like "*virtual machine*")
	{
		return 1
	}
	return 0
}

function Registry_Key_Query()
{
	Param($key)

	$output = @()
	try
	{
	    $obj = Get-ChildItem $key | Select-Object -Property Name
		if ($obj.length)
		{
			For ($i=0; $i -lt $obj.Length; $i++)
			{
				$name = $obj[$i].Name.Split("\\")[-1]
				$output += $name
			}
		}
		else
		{
			$name = $obj.Name.Split("\\")[-1]
			$output += $name
		}
	}
	catch
	{
		$ErrorMessage = $_.Exception.Message
	}
	return $output
}

function Registry_Values_Query() {
	Param($key)
	$names = @()
	$output = @()

	try
	{
		$obj = Get-Item -Path $key
		ForEach ($o in $obj)
		{
			$names += $o.GetValueNames()
		}
		if ($names.length)
		{
			$output += '{"' +$key+ '":{'
			ForEach ($name in $names)
			{
				$output += '"' +$name+ '":"' +$obj.GetValue($name)
				#$output += $obj.GetValue($name)
			}
		}
	}
	catch
	{
		$ErrorMessage = $_.Exception.Message
	}

	return $output
}


function WMI_Query()
{
	Param($class, $props)

	# make sure the class exists in the first place
	try
	{
		$placeholder = Get-WMIObject -Class $class
	}
	catch
	{
		$ErrorMessage = $_.Exception.Message
	}

	$output = @()
	try
	{
		$wmi = Get-WMIObject -Query "SELECT * FROM $class" | Select-Object -Property $props
		if ($wmi)
		{
			ForEach ($w in $wmi)
			{
				ForEach ($prop in $props)
				{
					$obj = New-Object -TypeName psobject
					$obj | Add-Member -MemberType NoteProperty -Name "property" -value $prop
					$obj | Add-Member -MemberType NoteProperty -Name "property_value" -value $w.$prop
					$output += $obj
					$obj = ''
				}
			}
		}
	}
	catch
	{
		$ErrorMessage = $_.Exception.Message
	}

	return $output
}
