Import-Module .\Invoke-AntiVM.psd1

$recent = loadRecentExplorerFiles

Write-Host "Explorer has $($recent.count) recent visited files"


$found = checkRecentExplorerFiles -MAX 10


if ($found) { 
    Write-Host -ForegroundColor RED “VM FOUND”
    }
else{
    Write-Host -ForegroundColor GREEN “VM NOT FOUND”
}

$WarningPreference = 'SilentlyContinue'

$installed = Get-Software

Write-Host "This host has $($installed.count) programs installed"


$found = checkInstalledSoftware -MAX 10


if ($found) { 
    Write-Host -ForegroundColor RED “VM FOUND”
    }
else{
    Write-Host -ForegroundColor GREEN “VM NOT FOUND”
}

Write-Host -ForegroundColor YELLOW “Check common hack tools”

$found = checkHackInstalledSoftware

if ($found) { 
    Write-Host -ForegroundColor RED “VM FOUND”
    }
else{
    Write-Host -ForegroundColor GREEN “VM NOT FOUND”
}
Write-Host -ForegroundColor YELLOW “Check total cores”

$cpu= Get-CPU

Write-Host $cores

$found = checkOldCPU -MAX 2

if ($found) { 
    Write-Host -ForegroundColor RED “VM FOUND”
    }
else{
    Write-Host -ForegroundColor GREEN “VM NOT FOUND”
}
  