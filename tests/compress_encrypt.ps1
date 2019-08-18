
function Decrypt-String($key, $encryptedStringWithIV) {
    $bytes = [System.Convert]::FromBase64String($encryptedStringWithIV)
    $IV = $bytes[0..15]
    $aesManaged = Create-AesManagedObject $key $IV
    $decryptor = $aesManaged.CreateDecryptor();
    $unencryptedData = $decryptor.TransformFinalBlock($bytes, 16, $bytes.Length - 16);
    $aesManaged.Dispose()
    return $unencryptedData
}

function Encrypt-Bytes($key, $bytes) {
    $aesManaged = Create-AesManagedObject $key
    $encryptor = $aesManaged.CreateEncryptor()
    $encryptedData = $encryptor.TransformFinalBlock($bytes, 0, $bytes.Length);
    [byte[]] $fullData = $aesManaged.IV + $encryptedData
    $aesManaged.Dispose()
    [System.Convert]::ToBase64String($fullData)
}

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

function Get-DecompressedByteArray {

	[CmdletBinding()]
    Param (
		[Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [byte[]] $byteArray = $(Throw("-byteArray is required"))
    )
	Process {
	    Write-Verbose "Get-DecompressedByteArray"
        $input = New-Object System.IO.MemoryStream( , $byteArray )
	    $output = New-Object System.IO.MemoryStream
        $gzipStream = New-Object System.IO.Compression.GzipStream $input, ([IO.Compression.CompressionMode]::Decompress)
	    $gzipStream.CopyTo( $output )
        $gzipStream.Close()
		$input.Close()
        return [System.Text.Encoding]::UTF8.GetString($output.ToArray())
    }
}

$key = Create-AesKey
$Key | out-file 'test.key'

$unencryptedString = Get-Content "local_small.json" | Out-String

Write-Output $unencryptedString

$compressed = Get-Compressed-String $unencryptedString

$encryptedString = Encrypt-Bytes $key $compressed

Write-Output $encryptedString

$decryptedCompressed = Decrypt-String $key $encryptedString

$originalString = Get-DecompressedByteArray -byteArray $decryptedCompressed

Write-Output $originalString