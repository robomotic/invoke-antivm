$module_path = ("{0}/Invoke-AntiVM/" -f $Env:PSModulePath.split(';')[0])

If(!(test-path $module_path )) {
New-Item -ItemType Directory -path $module_path 
}

Copy-Item ".\Invoke-*" -Destination $module_path 
#Get-Module -ListAvailable