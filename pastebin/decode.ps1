$files = Get-ChildItem -Path data\*.json

function Decrypt-String($key, $encryptedStringWithIV) {
    $keybytes = [System.Convert]::FromBase64String($key)
    $bytes = [System.Convert]::FromBase64String($encryptedStringWithIV)
    $IV = $bytes[0..15]
    $aesManaged = Create-AesManagedObject $keybytes $IV
    $decryptor = $aesManaged.CreateDecryptor();
    $unencryptedData = $decryptor.TransformFinalBlock($bytes, 16, $bytes.Length - 16);
    $aesManaged.Dispose()
    [System.Text.Encoding]::UTF8.GetString($unencryptedData).Trim([char]0)
}

ForEach ($file in $files) {
    Write-Host $file
    $encrypted = Get-Content $file
    $key = Get-Content '..\random.key'
   
    $document = Decrypt-String $key $encrypted 

    Write-Host $document

}