# Module Manifest

@{
    # Basic module information
    RootModule           = 'OSD.Workspace.psm1'
    ModuleVersion        = '25.4.9.1'
    GUID                 = '083be276-ac05-4da6-b72b-15a53e68c0c4'
    Author               = 'David Segura, Michael Escamilla'
    CompanyName          = 'osdeploy.com'
    Copyright            = '(c) 2025 David Segura @ osdeploy.com. All rights reserved.'
    Description          = 'OSD.Workspace PowerShell Module for OSDWorkspace'

    # PowerShell compatibility
    CompatiblePSEditions = @('Desktop')
    PowerShellVersion    = '7.5'

    # Exports
    AliasesToExport      = @()
    CmdletsToExport      = @()
    FunctionsToExport    = @(
        'Add-OSDWorkspaceSubmodule'
        'Build-OSDWorkspaceWinPE'
        'Get-OSDWorkspace'
        'Import-OSDWorkspaceWinOS'
        'New-OSDWorkspaceUSB'
        'New-OSDWorkspaceVM'
        'Remove-OSDWorkspaceSubmodule'
        'Update-OSDWorkspaceHelp'
        'Update-OSDWorkspaceSubmodule'
        'Update-OSDWorkspaceUSB'
    )
    
    # Private data for the module
    PrivateData          = @{
        PSData           = @{
            Tags         = @('OSDeploy', 'OSD', 'OSDWorkspace')
            LicenseUri = 'https://github.com/OSDeploy/OSD.Workspace/blob/main/LICENSE'
            ProjectUri = 'https://github.com/OSDeploy/OSD.Workspace'
        }
    }
}