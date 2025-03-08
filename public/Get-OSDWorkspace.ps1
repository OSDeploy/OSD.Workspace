function Get-OSDWorkspace {
    <#
    .SYNOPSIS
        Displays information about the OSDWorkspace PowerShell Module.

    .DESCRIPTION
        Dislays information about the OSDWorkspace PowerShell Module including Upcoming Events, Links to Resources, and Newest Functions.

    .EXAMPLE
        Get-OSDWorkspace
        Displays information about the OSDWorkspace PowerShell Module.

    .INPUTS
        None.

        You cannot pipe input to this cmdlet.

    .OUTPUTS
        None.

        This function does not return any output.

    .LINK
        https://github.com/OSDeploy/OSD.Workspace/blob/main/docs/Get-OSDWorkspace.md

    .NOTES
        David Segura
    #>
    [CmdletBinding()]
    param ()
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
    $Error.Clear()
    #=================================================
    Write-Host -ForegroundColor DarkCyan "OSDWorkspace Team"
    Write-Host -ForegroundColor DarkGray "David Segura https://linkedin.com/in/davidsegura/"
    Write-Host -ForegroundColor DarkGray "Michael Escamilla https://linkedin.com/in/michael-a-escamilla/"
    Write-Host
    Write-Host -ForegroundColor DarkCyan "NWSCUG: OSDWorkspace Preview"
    Write-Host -ForegroundColor DarkGray "March 21, 2025"
    Write-Host -ForegroundColor DarkGray "https://nwscug.org/"
    Write-Host
    Write-Host -ForegroundColor DarkCyan "MMSMOA: OSDWorkspace / OSDCloud"
    Write-Host -ForegroundColor DarkGray "May 5-8, 2025"
    Write-Host -ForegroundColor DarkGray "https://mmsmoa.com/"
    Write-Host
    Write-Host -ForegroundColor DarkCyan "WPNinjasUK: OSDWorkspace / OSDCloud"
    Write-Host -ForegroundColor DarkGray "June 16-17, 2025"
    Write-Host -ForegroundColor DarkGray 'https://wpninjas.uk/'
    Write-Host
    Write-Host -ForegroundColor DarkCyan 'OSDWorkspace PowerShell Module - PowerShell Gallery'
    Write-Host -ForegroundColor DarkGray 'https://www.powershellgallery.com/packages/OSDWorkspace'
    Write-Host
    Write-Host -ForegroundColor DarkCyan 'OSDWorkspace PowerShell Module - GitHub Repository'
    Write-Host -ForegroundColor DarkGray 'https://github.com/OSDeploy/OSDWorkspace'
    Write-Host
    Write-Host -ForegroundColor DarkCyan 'OSDWorkspace PowerShell Module - Issues / Support'
    Write-Host -ForegroundColor DarkGray 'https://github.com/OSDeploy/OSDWorkspace/issues'
    Write-Host
    Write-Host -ForegroundColor DarkCyan 'OSDWorkspace: GitHub Template Repository'
    Write-Host -ForegroundColor DarkGray 'https://github.com/OSDeploy/OSDWorkspace-Template'
    Write-Host
    Write-Host -ForegroundColor DarkCyan 'OSDWorkspace: Community WinPEDriver Repositories'
    Write-Host -ForegroundColor DarkGray 'https://github.com/OSDeploy/WinPEDriver-HP'
    Write-Host -ForegroundColor DarkGray 'https://github.com/OSDeploy/WinPEDriver-Dell'
    Write-Host -ForegroundColor DarkGray 'https://github.com/OSDeploy/WinPEDriver-Surface'
    Write-Host -ForegroundColor DarkGray 'https://github.com/OSDeploy/WinPEDriver-Generic'
    Write-Host
    Write-Host -ForegroundColor DarkCyan 'OSDWorkspace: Community Library Repositories'
    Write-Host -ForegroundColor DarkGray 'https://github.com/OSDeploy/OSDWorkspace-Library-OSDCloud'
    Write-Host -ForegroundColor DarkGray 'https://github.com/OSDeploy/OSDWorkspace-Library-OSDCloud-MSP'
    Write-Host -ForegroundColor DarkGray 'https://github.com/OSDeploy/OSDWorkspace-Library-OSDCloud-Vault'
    Write-Host -ForegroundColor DarkGray 'https://github.com/OSDeploy/OSDWorkspace-Library-BlackLotus'
    Write-Host -ForegroundColor DarkGray 'https://github.com/OSDeploy/OSDWorkspace-Library-WindowsUpdate'
    Write-Host -ForegroundColor DarkGray 'https://github.com/OSDeploy/OSDWorkspace-Segura'
    Write-Host
    Write-Host -ForegroundColor DarkCyan 'OSDWorkspace: Quick Start'
    Write-Host -ForegroundColor DarkGray 'Import-OSDWorkspaceWinOS'
    Write-Host -ForegroundColor DarkGray 'Build-OSDWorkspaceWinPE'
    Write-Host -ForegroundColor DarkGray 'New-OSDWorkspaceVM'
    Write-Host -ForegroundColor DarkGray 'New-OSDWorkspaceUSB'
    Write-Host
    Write-Host -ForegroundColor DarkCyan 'OSDWorkspace: Details'
    Write-Host -ForegroundColor DarkGreen "Get-OSDWorkspacePath: $(Get-OSDWorkspacePath)"
    Write-Host
    Write-Host -ForegroundColor DarkCyan 'OSDWorkspace: Newest Functions and Updates'
    Write-Host -ForegroundColor DarkGreen 'Import-OSDWorkspaceWinPEDriverCM'
    Write-Host -ForegroundColor DarkGreen 'Import-OSDWorkspaceWinPEDriverMDT'
    Write-Host
    Write-Host -ForegroundColor DarkGray "Get-OSDWorkspaceCachePath: $(Get-OSDWorkspaceCachePath)"
    Write-Host -ForegroundColor DarkGray "Get-OSDWorkspaceCacheAdkPath: $(Get-OSDWorkspaceCacheAdkPath)"

    Write-Host -ForegroundColor DarkGray "Get-OSDWorkspaceImportPath: $(Get-OSDWorkspaceImportPath)"
    Write-Host -ForegroundColor DarkGray "Get-OSDWorkspaceImportWinREPath: $(Get-OSDWorkspaceImportWinREPath)"
    Write-Host -ForegroundColor DarkGray "Get-OSDWorkspaceImportWinOSPath: $(Get-OSDWorkspaceImportWinOSPath)"

    Write-Host -ForegroundColor DarkGray "Get-OSDWorkspaceLibraryPath: $(Get-OSDWorkspaceLibraryPath)"
    Write-Host -ForegroundColor DarkGray "Get-OSDWorkspaceGitHubPath: $(Get-OSDWorkspaceGitHubPath)"
    Write-Host -ForegroundColor DarkGray "Get-OSDWorkspaceMediaPath: $(Get-OSDWorkspaceMediaPath)"
    Write-Host -ForegroundColor DarkGray "Get-OSDWorkspaceMediaWinPEPath: $(Get-OSDWorkspaceMediaWinPEPath)"
    Write-Host -ForegroundColor DarkGray "Get-OSDWorkspaceMediaWinOSPath: $(Get-OSDWorkspaceMediaWinOSPath)"

    $null = Get-OSDWorkspaceImportWinRE
    $null = Get-OSDWorkspaceImportWinOS
    $null = Get-OSDWorkspaceMediaWinPE
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}