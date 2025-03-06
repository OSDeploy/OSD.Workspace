function Get-OSDWorkspaceLibraryBootDriver {
    <#
    .SYNOPSIS
        Returns available OSDWorkspace Library BootDriver(s).

    .DESCRIPTION
        This function returns available OSDWorkspace Library and Library-GitHub BootDriver(s).
        Utilizes the Get-OSDWorkspaceBootImage and Get-OSDWorkspaceGitHubPath functions to retrieve the BootDriver Path(s)

    .INPUTS
        None.

        You cannot pipe input to this cmdlet.

    .OUTPUTS
        System.Array

        This function returns the available boot drivers in the OSDWorkspace Library.

    .EXAMPLE
        Get-OSDWorkspaceLibraryBootDriver
        Returns the boot drivers in the OSDWorkspace Library.

    .EXAMPLE
        Get-OSDWorkspaceLibraryBootDriver -Architecture amd64
        Returns the boot drivers in the OSDWorkspace Library filtered by architecture.

    .EXAMPLE
        Get-OSDWorkspaceLibraryBootDriver -BootImage ADK
        Returns the boot drivers in the OSDWorkspace Library filtered by boot image.

    .NOTES
        David Segura
    #>
    [CmdletBinding()]
    param (
        # Filters the drivers by architecture (amd64, arm64)
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateSet('amd64', 'arm64')]
        [System.String]
        $Architecture,

        # Filters the drivers by boot image (ADK, WinPE, WinRE) by excluding Wireless drivers for ADK and WinPE
        [Parameter(Mandatory = $false)]
        [ValidateSet('ADK', 'WinPE', 'WinRE')]
        [System.String]
        $BootImage
    )
    #=================================================
    $Error.Clear()
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
    #=================================================
    $LibraryPaths = @()
    $LibraryPaths += Get-OSDWorkspaceLibraryPath

    $LibraryGitPaths = Get-OSDWorkspaceGitHubPath
    foreach ($LibraryGitPath in $LibraryGitPaths) {
        $LibraryPaths += Get-ChildItem -Path $LibraryGitPath -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName
    }
    
    $LibraryItems = @()
    $LibraryItems = foreach ($LibraryPath in $LibraryPaths) {
        Get-ChildItem -Path @("$LibraryPath\BootDriver\*\*") -ErrorAction SilentlyContinue | `
            Where-Object { $_.PSIsContainer -eq $true } | `
            Select-Object Name, @{Name = 'Architecture'; Expression = { $_.Parent } }, FullName, LastWriteTime
    }

    # Ensure the Driver Repository uses the proper Architecture folder structure
    $LibraryItems = $LibraryItems | Where-Object { ($_.Architecture -match 'amd64') -or ($_.Architecture -match 'arm64') } | Sort-Object -Property Architecture, FullName

    if ($Architecture) {
        $LibraryItems = $LibraryItems | Where-Object { $_.Architecture -match $Architecture }
    }

    if (($BootImage -eq 'ADK') -or ($BootImage -eq 'WinPE')) {
        $LibraryItems = $LibraryItems | Where-Object { $_.Name -notmatch 'Wireless' }
    }
    $LibraryItems
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}