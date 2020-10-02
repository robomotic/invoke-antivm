# these functions should really get multithreaded in the future

function checkMouseMovement()
{
	$output = @()

	Try
	{
		Add-Type -AssemblyName System.Windows.Forms
		$start = [System.Windows.Forms.Cursor]::Position
		Start-Sleep -s 5
		$end = [System.Windows.Forms.Cursor]::Position

		if ($start.x -eq $end.x -and $start.y -eq $end.y)
		{
			$obj = New-Object -TypeName psobject
			$obj | Add-Member -MemberType NoteProperty -Name "status" -value 2
			$obj | Add-Member -MemberType NoteProperty -Name "class" -value "User Input"
			$obj | Add-Member -MemberType NoteProperty -Name "property" -value "Mouse"
			$obj | Add-Member -MemberType NoteProperty -Name "property_value" -value "No movement"
			$output += $obj
		}
	}
	Catch {}

	return $output
}

# Work in Progress
function checkKeyPress
{
    $found = 1  # better to assume already running inside a VM
    $output = @()

    $signature = @'
    [DllImport("user32.dll")]
    public static extern short GetAsyncKeyState(int virtualKeyCode);
'@


    $getKeyState = Add-Type -memberDefinition $signature -name "Newtype" -namespace newnamespace -passThru
    for ($i=0; $i -lt 10000; $i++)
    {
        #Start-Sleep -Milliseconds 40
        $logged = ""
        for ($vkey=1;$vkey -le 254;$vkey++)
        {
            $logged = $getKeyState::GetAsyncKeyState($vkey)
            if ($logged -eq -32767) # key pressed = -32767
            {
                $found = 0
                $values = "Keypress detected - int($($vkey))"
                return ($found, $values)
            }
        }
    }

    return ($found, $values)
}
