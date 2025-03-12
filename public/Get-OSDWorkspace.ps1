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
    $Error.Clear()
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
    Initialize-OSDWorkspace
    #=================================================
    Write-Host -ForegroundColor DarkCyan 'OSDWorkspace Team'
    Write-Host -ForegroundColor DarkGray "David Segura | $($OSDWorkspace.links.david)"
    Write-Host -ForegroundColor DarkGray "Michael Escamilla | $($OSDWorkspace.links.michael)"
    Write-Host
    Write-Host -ForegroundColor DarkCyan 'NWSCUG: OSD 2025 Preview'
    Write-Host -ForegroundColor DarkGray "March 28, 2025 | $($OSDWorkspace.links.nwscug)"
    Write-Host
    Write-Host -ForegroundColor DarkCyan 'MMSMOA: OSDWorkspace and OSDCloud 2025'
    Write-Host -ForegroundColor DarkGray "May 5-8, 2025 | $($OSDWorkspace.links.mmsmoa)"
    Write-Host
    Write-Host -ForegroundColor DarkCyan 'WPNinjasUK: OSDWorkspace and OSDCloud 2025'
    Write-Host -ForegroundColor DarkGray "June 16-17, 2025 | $($OSDWorkspace.links.wpninjasuk)"
    Write-Host
    Write-Host -ForegroundColor DarkCyan 'WPNinjas: OSDWorkspace and OSDCloud 2025'
    Write-Host -ForegroundColor DarkGray "September 22-25, 2025 | $($OSDWorkspace.links.wpninjasch)"
    Write-Host
    Write-Host -ForegroundColor DarkCyan 'OSDWorkspace on GitHub'
    Write-Host -ForegroundColor DarkGray $($OSDWorkspace.links.github)
    Write-Host
    Write-Host -ForegroundColor DarkCyan 'OSDWorkspace on PowerShell Gallery'
    Write-Host -ForegroundColor DarkGray $($OSDWorkspace.links.powershellgallery)
    Write-Host
    Write-Host -ForegroundColor DarkCyan 'OSDWorkspace on Discord'
    Write-Host -ForegroundColor DarkGray $($OSDWorkspace.links.discord)
    #=================================================
    #endregion
    $null = Get-OSDWSWinRESource -WarningAction SilentlyContinue
    $null = Get-OSDWSWinOSSource -WarningAction SilentlyContinue
    $null = Get-OSDWSWinPEBuild -WarningAction SilentlyContinue
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}