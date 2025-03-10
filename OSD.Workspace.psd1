@{
    Author               = 'David Segura, Michael Escamilla'
    CompanyName          = 'osdeploy.com'
    CompatiblePSEditions = @('Desktop')
    Copyright            = '(c) 2025 David Segura @ osdeploy.com. All rights reserved.'
    Description          = 'OSD.Workspace PowerShell Module for OSDWorkspace'
    GUID                 = '083be276-ac05-4da6-b72b-15a53e68c0c4'
    ModuleVersion        = '25.3.7.1'
    PowerShellVersion    = '5.1'
    RootModule           = 'OSD.Workspace.psm1'
    FunctionsToExport    = @(
        'Build-OSDWorkspaceWinPE'
        'Get-OSDWorkspace'
        'Add-OSDWorkspaceRemoteLibrary'
        'Import-OSDWorkspaceSettings'
        'Import-OSDWorkspaceWinOS'
        'New-OSDWorkspaceUSB'
        'New-OSDWorkspaceVM'
        'Open-OSDWorkspace'
        'Update-OSDWorkspaceRemoteLibrary'
        'Update-OSDWorkspaceUSB'
        'Select-OSDWSGitHubRepo'
        'Remove-OSDWorkspaceRemoteLibrary'
    )
    PrivateData          = @{
        PSData = @{
            IconUri      = 'https://raw.githubusercontent.com/OSDeploy/OSD.Workspace/main/OSD.png'
            LicenseUri   = 'https://github.com/OSDeploy/OSD.Workspace/blob/main/LICENSE'
            ProjectUri   = 'https://github.com/OSDeploy/OSD.Workspace'
            ReleaseNotes = 'https://github.com/OSDeploy/OSD.Workspace/blob/main/CHANGELOG.md'
            Tags         = @('OSDeploy', 'OSD', 'OSDWorkspace', 'OSDWorkflow', 'OSDCloud')
        }
    }
}