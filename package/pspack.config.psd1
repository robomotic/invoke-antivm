@{
    Root = ".\fingerprint_payload.ps1";
    OutputPath = ".\prober";
    Bundle = @{
        Enabled = $true;
        Modules = $true;
        NestedModules = $true;
        RequiredAssemblies = $true;
    }
    Package = @{
        Enabled = $true
        Obfuscate = $true
    }
}