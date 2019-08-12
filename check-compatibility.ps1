# for more configurations: https://devblogs.microsoft.com/powershell/using-psscriptanalyzer-to-check-powershell-version-compatibility/
$settings = @{
    ExcludeRules = @('PSPossibleIncorrectComparisionWithNull',
        'PSAvoidTrailingWhitespace',
        'PSUseShouldProcessForStateChangingFunctions',
        'PSUseSingularNouns',
        'PSAvoidUsingInvokeExpression')

    Rules        = @{
        PSUseCompatibleSyntax = @{
            # This turns the rule on (setting it to false will turn it off)
            Enable         = $true
 
            # List the targeted versions of PowerShell here
            TargetVersions = @(
                '1.0',
                '2.0',
                '3.0',
                '4.0',
                '5.0',
                '5.1',
                '6.0',
                '6.1',
                '6.2'
            )
        }
    }
}
 
Invoke-ScriptAnalyzer -Path .\Invoke-AntiVM.psd1 -Settings $settings
Invoke-ScriptAnalyzer -Path .\Invoke-AntiVM.ps1 -Settings $settings
Invoke-ScriptAnalyzer -Path .\Invoke-AntiVM-CPU.ps1 -Settings $settings
Invoke-ScriptAnalyzer -Path .\Invoke-AntiVM-Execution.ps1 -Settings $settings
Invoke-ScriptAnalyzer -Path .\Invoke-AntiVM-Network.ps1 -Settings $settings
Invoke-ScriptAnalyzer -Path .\Invoke-AntiVM-Programs.ps1 -Settings $settings
Invoke-ScriptAnalyzer -Path .\Invoke-FingerPrintVM.ps1 -Settings $settings