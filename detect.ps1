Import-Module .\Invoke-AntiVM.psd1

# supress noisy errors
$ErrorActionPreference = 'stop'

$checks = @(Get-Item function:checkHyperV,	# Invoke-AntiVM-Hardware.ps1
				function:checkEnvironment,	# Invoke-AntiVM-Environment.ps1
				function:checkWallpaper,	# Invoke-AntiVM-Environment.ps1
				function:checkBiosRegistry,	# Invoke-AntiVM-Hardware.ps1
				function:checkIdeChannels,	# Invoke-AntiVM-Hardware.ps1
				function:checkPnP,	# Invoke-AntiVM-Hardware.ps1
				function:checkSoundDevice,	# Invoke-AntiVM-Hardware.ps1
				function:checkSystemEnclosure,	# Invoke-AntiVM-Hardware.ps1
				function:checkBiosWmi,	# Invoke-AntiVM-Hardware.ps1
				function:checkComputerSystem,	# Invoke-AntiVM-Environment.ps1
				function:checkComputerSystemProduct,	# Invoke-AntiVM-Environment.ps1
				function:checkDiskDrive,	# Invoke-AntiVM-Hardware.ps1
				function:checkDisplayConfiguration,	# Invoke-AntiVM-Hardware.ps1
				function:checkDisplayControllerConfiguration,	# Invoke-AntiVM-Hardware.ps1
				function:checkNetworkAdapter,	# Invoke-AntiVM-Network.ps1
				function:checkNetworkAdapterConfiguration,	# Invoke-AntiVM-Network.ps1
				function:checkOnBoardDevice,	# Invoke-AntiVM-Hardware.ps1
				function:checkPhysicalMemory,	# Invoke-AntiVM-Hardware.ps1
				function:checkServices,	# Invoke-AntiVM-Execution.ps1
				function:checkProcesses,	# Invoke-AntiVM-Execution.ps1
				function:checkFiles,	# Invoke-AntiVM-Environment.ps1
				function::checkFilesExplorer,	# Invoke-AntiVM-Environment.ps1
				function::checkFilesOffice,	# Invoke-AntiVM-Environment.ps1
				function:checkInstalledProgramsRegistry,	# Invoke-AntiVM-Programs.ps1
				#function:checkHackInstalledSoftware,	# WIP - backwards compatibility
				function:checkVideoController,	# Invoke-AntiVM-Hardware.ps1
				function:checkMouseMovement	# Invoke-AntiVM-Interaction.ps1
)
$found = 0


foreach ($check in $checks)
{
    $objects = & $check

	ForEach ($obj in $objects)
	{
		if ($obj.class)
		{
			$str = $obj.class +': '+ $obj.property +' = '+ $obj.property_value
			if ($obj.status -eq 1)
		    {
				$found = 1
		        Write-Host -ForegroundColor RED "VM FOUND"
		    }
			elseif ($obj.status -eq 2)
		    {
				$found = 1
		        Write-Host -ForegroundColor YELLOW "POSSIBLE VM"
		    }
			Write-Host -ForegroundColor WHITE "    - $str"
		}
	}
}

if (!$found)
{
	Write-Host -ForegroundColor GREEN "NO VM FOUND!"
}
