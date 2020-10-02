# resources:
#   https://resources.infosecinstitute.com/pafish-paranoid-fish/
#   https://www.thewindowsclub.com/clear-most-recently-used-mru-list
#   https://www.cyberbit.com/blog/endpoint-security/anti-vm-and-anti-sandbox-explained/
#       1) checking cpu instructions
#           - cpuid --> http://waynes-world-it.blogspot.com/2009/06/calling-cpuid-from-powershell-for-intel.html
#           - mmx
#           - in
#       2) known MAC addresses
#   http://webcache.googleusercontent.com/search?q=cache:FRZ2kko0NG8J:pentestit.com/al-khaser-benign-malware-test-anti-malware/+&cd=12&hl=en&ct=clnk&gl=us
#   https://github.com/nicehash/NiceHashMiner-Archived/blob/master/NiceHashMiner/PInvoke/CPUID.cs

function checkNetworkAdapter()
{
	$props = @("Name", "Caption", "Description", "Manufacturer", "ProductName", "ServiceName", "MACAddress")
	$class = "Win32_NetworkAdapter"
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
		if ($obj.property -eq "macaddress")
		{
			if ($obj.property_value -like "00:05:69*" -or $obj.property_value -like "00:0C:29*" -or $obj.property_value -like "00:1C:14*" -or $obj.property_value -like "00:50:56*")
			{
				$obj | Add-Member -MemberType NoteProperty -Name "status" -value 1
				$obj | Add-Member -MemberType NoteProperty -Name "class" -value $class
				$output += $obj
			}
			elseif ($obj.property_value -like "08:00:27*")
			{
				$obj | Add-Member -MemberType NoteProperty -Name "status" -value 1
				$obj | Add-Member -MemberType NoteProperty -Name "class" -value $class
				$output += $obj
			}
		}
	}
	return $output
}

function checkNetworkAdapterConfiguration()
{
	$props = @("Caption", "Description", "DHCPLeaseObtained", "DNSHostName", "IPAddress", "MACAddress", "ServiceName")
	$class = "Win32_NetworkAdapterConfiguration"
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
