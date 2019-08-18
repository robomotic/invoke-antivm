# these functions should really get multithreaded in the future


function checkMouseMovement
{
    $found = 0
    $values = @()


    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
    $start = [System.Windows.Forms.Cursor]::Position
    
    Start-Sleep -Seconds 5
    
    $end = [System.Windows.Forms.Cursor]::Position
    
    if ($start.X -eq $end.X)
    {
        if ($start.Y -eq $end.Y)
        {
            $found = 1
            $values += "Mouse movement not detected"
        }
    }
    
    return ($found, $values)
}

function checkKeyPress
{
    $found = 1  # better to assume already running inside a VM
    $values = @()
    $values += "No keypresses detected"
    
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
