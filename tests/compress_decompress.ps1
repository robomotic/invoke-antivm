# Compress and decompress byte array
  
function Get-CompressedByteArray {

	[CmdletBinding()]
    Param (
	[Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [byte[]] $byteArray = $(Throw("-byteArray is required"))
    )
	Process {
        Write-Verbose "Get-CompressedByteArray"
       	[System.IO.MemoryStream] $output = New-Object System.IO.MemoryStream
        $gzipStream = New-Object System.IO.Compression.GzipStream $output, ([IO.Compression.CompressionMode]::Compress)
      	$gzipStream.Write( $byteArray, 0, $byteArray.Length )
        $gzipStream.Close()
        $output.Close()
        $tmp = $output.ToArray()
        Write-Output $tmp
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
		[byte[]] $byteOutArray = $output.ToArray()
        Write-Output $byteOutArray
    }
}

[string] $text = "some text to encode"
Write-Host "Text: " ( $text | Out-String )

[System.Text.Encoding] $enc = [System.Text.Encoding]::UTF8
[byte[]] $encText = $enc.GetBytes( $text )

$compressedByteArray = Get-CompressedByteArray -byteArray $encText
Write-Host "Encoded: " ( $enc.GetString( $compressedByteArray ) | Out-String )

$decompressedByteArray = Get-DecompressedByteArray -byteArray $compressedByteArray
Write-Host "Decoded: " ( $enc.GetString( $decompressedByteArray ) | Out-String )