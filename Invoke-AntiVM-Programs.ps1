
Function Get-Software {

    [OutputType('System.Software.Inventory')]

    [Cmdletbinding()]

    Param(

        [Parameter(ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]

        [String[]]$Computername = $env:COMPUTERNAME

    )

    Begin {

    }

    Process {

        ForEach ($Computer in  $Computername) {

            If (Test-Connection -ComputerName  $Computer -Count  1 -Quiet) {

                $Paths = @("SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall", "SOFTWARE\\Wow6432node\\Microsoft\\Windows\\CurrentVersion\\Uninstall")

                ForEach ($Path in $Paths) {

                    Write-Verbose  "Checking Path: $Path"

                    #  Create an instance of the Registry Object and open the HKLM base key

                    Try {

                        $reg = [microsoft.win32.registrykey]::OpenRemoteBaseKey('LocalMachine', $Computer, 'Registry64')

                    }
                    Catch {

                        Write-Error $_

                        Continue

                    }

                    #  Drill down into the Uninstall key using the OpenSubKey Method

                    Try {

                        $regkey = $reg.OpenSubKey($Path)

                        # Retrieve an array of string that contain all the subkey names

                        $subkeys = $regkey.GetSubKeyNames()

                        # Open each Subkey and use GetValue Method to return the required  values for each

                        ForEach ($key in $subkeys) {

                            Write-Verbose "Key: $Key"

                            $thisKey = $Path + "\\" + $key

                            Try {

                                $thisSubKey = $reg.OpenSubKey($thisKey)

                                # Prevent Objects with empty DisplayName

                                $DisplayName = $thisSubKey.getValue("DisplayName")

                                If ($DisplayName -AND $DisplayName -notmatch '^Update  for|rollup|^Security Update|^Service Pack|^HotFix') {

                                    $Date = $thisSubKey.GetValue('InstallDate')

                                    If ($Date) {

                                        Try {

                                            $Date = [datetime]::ParseExact($Date, 'yyyyMMdd', $Null)

                                        }
                                        Catch {

                                            Write-Warning "$($Computer): $_ <$($Date)>"

                                            $Date = $Null

                                        }

                                    }

                                    # Create New Object with empty Properties

                                    $Publisher = Try {

                                        $thisSubKey.GetValue('Publisher').Trim()

                                    }

                                    Catch {

                                        $thisSubKey.GetValue('Publisher')

                                    }

                                    $Version = Try {

                                        #Some weirdness with trailing [char]0 on some strings

                                        $thisSubKey.GetValue('DisplayVersion').TrimEnd(([char[]](32, 0)))

                                    }

                                    Catch {

                                        $thisSubKey.GetValue('DisplayVersion')

                                    }

                                    $UninstallString = Try {

                                        $thisSubKey.GetValue('UninstallString').Trim()

                                    }

                                    Catch {

                                        $thisSubKey.GetValue('UninstallString')

                                    }

                                    $InstallLocation = Try {

                                        $thisSubKey.GetValue('InstallLocation').Trim()

                                    }

                                    Catch {

                                        $thisSubKey.GetValue('InstallLocation')

                                    }

                                    $InstallSource = Try {

                                        $thisSubKey.GetValue('InstallSource').Trim()

                                    }

                                    Catch {

                                        $thisSubKey.GetValue('InstallSource')

                                    }

                                    $HelpLink = Try {

                                        $thisSubKey.GetValue('HelpLink').Trim()

                                    }

                                    Catch {

                                        $thisSubKey.GetValue('HelpLink')

                                    }

                                    $Object = [pscustomobject]@{

                                        Computername    = $Computer

                                        DisplayName     = $DisplayName

                                        Version         = $Version

                                        InstallDate     = $Date

                                        Publisher       = $Publisher

                                        UninstallString = $UninstallString

                                        InstallLocation = $InstallLocation

                                        InstallSource   = $InstallSource

                                        HelpLink        = $thisSubKey.GetValue('HelpLink')

                                        EstimatedSizeMB = [decimal]([math]::Round(($thisSubKey.GetValue('EstimatedSize') * 1024) / 1MB, 2))

                                    }

                                    $Object.pstypenames.insert(0, 'System.Software.Inventory')

                                    Write-Output $Object

                                }

                            }
                            Catch {

                                Write-Warning "$Key : $_"

                            }

                        }

                    }
                    Catch { }

                    $reg.Close()

                }

            }
            Else {

                Write-Error  "$($Computer): unable to reach remote system!"

            }

        }

    }

}


Function checkInstalledSoftware {

    Param(
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [Int]$MAX
    )
    Process {
        $recent = Get-Software
        if ($recent.count -lt $MAX) {
            return $true
        }
        else { return $false }
    }
}



Function checkHackInstalledSoftware {

    $hacktools = @("vmware", "vmtools", "vbox", "process explorer", "processhacker", "procmon", "visual basic", "fiddler", "wireshark")
	$output = @()

    $programs = Get-Software

    Foreach ($installed in $programs) {

        Foreach ($hacktool in $hacktools) {
            if ($installed.DisplayName) {
                if ($installed.DisplayName.ToLower() -like "*$hacktool*") {
					$obj = New-Object -TypeName psobject
					$obj | Add-Member -MemberType NoteProperty -Name "status" -value 1
					$obj | Add-Member -MemberType NoteProperty -Name "class" -value "Installed Programs"
					$obj | Add-Member -MemberType NoteProperty -Name "property" -value "Hacktool"
					$obj | Add-Member -MemberType NoteProperty -Name "property_value" -value $obj
					$output += $obj
                }
            }
        }
    }
    return $output

}

function checkInstalledProgramsRegistry()
{
	$keys = @()
	$keys += "HKLM:\Software"
	$keys += "HKLM:\Software\Wow6432Node"
	$keys += "HKCU:\Software"
	$keys += "HKCU:\Software\Wow6432Node"
	$output = @()
	$count = 0

	Foreach ($k in $keys) {
		$objects = Registry_Key_Query $k
		ForEach ($obj in $objects)
		{
			$common = Common_String $obj
			$count += 1
			if ($common)
			{
				$obj | Add-Member -MemberType NoteProperty -Name "status" -value 1
				$obj | Add-Member -MemberType NoteProperty -Name "class" -value "Installed Programs"
				$obj | Add-Member -MemberType NoteProperty -Name "property" -value "Virtual"
				$obj | Add-Member -MemberType NoteProperty -Name "property_value" -value $obj
				$output += $obj
			}
			if ($obj -like "*netscape*")
			{
				$obj | Add-Member -MemberType NoteProperty -Name "status" -value 2
				$obj | Add-Member -MemberType NoteProperty -Name "class" -value "Installed Programs"
				$obj | Add-Member -MemberType NoteProperty -Name "property" -value "Browser"
				$obj | Add-Member -MemberType NoteProperty -Name "property_value" -value $obj
				$output += $obj
			}
		}
	}

	if ($count -lt 50)
	{
		$obj = New-Object -TypeName psobject
		$obj | Add-Member -MemberType NoteProperty -Name "status" -value 2
		$obj | Add-Member -MemberType NoteProperty -Name "class" -value "Installed Programs"
		$obj | Add-Member -MemberType NoteProperty -Name "property" -value "Count"
		$obj | Add-Member -MemberType NoteProperty -Name "property_value" -value $count
		$output += $obj
	}
	return $output
}
