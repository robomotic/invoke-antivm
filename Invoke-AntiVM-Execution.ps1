function checkProcesses()
{
	$props = @("Caption", "Description", "Name", "ProcessName", "CommandLine", "ExecutablePath", "Path")
	$class = "Win32_Process"
	$objects = WMI_Query $class $props
	$output = @()
	$others = @("vmxnet*", "vmusrvc.ex*", "vmsrvc.ex*", "vmtoolsd*", "vmwaretray.ex*", "vmwareuser.ex*", "vmwareuser.ex*", "vmwaretrat*", "vmacthlp*")
	$others += "vboxservice*"
	$others += "vboxtray*"
	$others += "xenservice.ex*"

	ForEach ($obj in $objects)
	{
		$common = Common_String $obj.property_value
		if ($common)
		{
			$obj | Add-Member -MemberType NoteProperty -Name "status" -value 1
			$obj | Add-Member -MemberType NoteProperty -Name "class" -value $class
			$output += $obj
		}
		else
		{
			ForEach($o in $others)
			{
				if ($obj.property_value -like $o)
				{
					$obj | Add-Member -MemberType NoteProperty -Name "status" -value 1
					$obj | Add-Member -MemberType NoteProperty -Name "class" -value $class
					$output += $obj
				}
			}
		}
	}
	return $output
}

function checkServices()
{
	$props = @("DisplayName", "Description", "PathName", "State", "StartMode", "StartName")
	$class = "Win32_Service"
	$objects = WMI_Query $class $props
	$output = @()
	$others = @("vmtools*", "vmhgfs*", "vmmemctl*", "vmmouse*", "vmrawdsk*", "vmusbmouse*", "vmvss*", "vmscsi*", "vmxnet*", "vmx_svga*", "vmware tools*", "vmware physical disk helper service*")

	ForEach ($obj in $objects)
	{
		$common = Common_String $obj.property_value
		if ($common)
		{
			$obj | Add-Member -MemberType NoteProperty -Name "status" -value 1
			$obj | Add-Member -MemberType NoteProperty -Name "class" -value $class
			$output += $obj
		}
		else
		{
			ForEach($o in $others)
			{
				if ($obj.property_value -like $o)
				{
					$obj | Add-Member -MemberType NoteProperty -Name "status" -value 1
					$obj | Add-Member -MemberType NoteProperty -Name "class" -value $class
					$output += $obj
				}
			}
		}
	}
	return $output
}
