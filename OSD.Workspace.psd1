@{
    Author               = 'David Segura, Michael Escamilla'
    CompanyName          = 'osdeploy.com'
    CompatiblePSEditions = @('Desktop')
    Copyright            = '(c) 2025 @ osdeploy.com. All rights reserved.'
    Description          = 'OSD.Workspace PowerShell Module for OSDWorkspace'
    GUID                 = '083be276-ac05-4da6-b72b-15a53e68c0c4'
    ModuleVersion        = '25.3.28.1'
    PowerShellVersion    = '7.5'
    RootModule           = 'OSD.Workspace.psm1'
    FunctionsToExport    = @(
        'Add-OSDWorkspaceSubmodule'
        'Build-OSDWorkspaceWinPE'
        'Get-OSDWorkspace'
        'Import-OSDWorkspaceWinOS'
        'Initialize-OSDWorkspace'
        'New-OSDWorkspaceUSB'
        'New-OSDWorkspaceVM'
        'Remove-OSDWorkspaceSubmodule'
        'Update-OSDWorkspaceHelp'
        'Update-OSDWorkspaceSubmodule'
        'Update-OSDWorkspaceUSB'
    )
    PrivateData          = @{
        PSData = @{
            ProjectUri = 'https://github.com/OSDeploy/OSD.Workspace'
            LicenseUri = 'https://github.com/OSDeploy/OSD.Workspace/blob/main/LICENSE'
            IconUri    = 'https://raw.githubusercontent.com/OSDeploy/OSD.Workspace/main/OSD.png'
            Tags       = @('OSDeploy', 'OSD', 'OSDWorkspace', 'OSDCloud')
        }
    }
}