function Get-OSDWSWinPEBuildDriver {
    <#
    .SYNOPSIS
        Returns available OSDWorkspace Library WinPEDriver(s).

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

    # Get the OSDWorkspace Library Subfolders
    $LibraryLocal = $OSDWorkspace.paths.library_local
    foreach ($Subfolder in $LibraryLocal) {
        $LibraryPaths += Get-ChildItem -Path $Subfolder -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName
    }

    # Get the OSDWorkspace Public Subfolders
    $LibraryShared = $OSDWorkspace.paths.library_submodule
    foreach ($Subfolder in $LibraryShared) {
        $LibraryPaths += Get-ChildItem -Path $Subfolder -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName
    }
    
    $LibraryItems = @()
    $LibraryItems = foreach ($LibraryPath in $LibraryPaths) {
        Get-ChildItem -Path @("$LibraryPath\winpe-driver\*\*") -ErrorAction SilentlyContinue | `
            Where-Object { $_.PSIsContainer -eq $true } | `
            Select-Object @{Name = 'Type'; Expression = { 'winpe-driver' } },
            Name, @{Name = 'Architecture'; Expression = { ($_.Parent | Split-Path -Leaf) } }, FullName, LastWriteTime
    }

    # Ensure the Driver Repository uses the proper Architecture folder structure
    $LibraryItems = $LibraryItems | Where-Object { ($_.Architecture -match 'amd64') -or ($_.Architecture -match 'arm64') } | Sort-Object -Property Architecture, FullName

    if ($Architecture) {
        $LibraryItems = $LibraryItems | Where-Object { $_.Architecture -match $Architecture }
    }

    if (($BootImage -eq 'ADK') -or ($BootImage -eq 'WinPE')) {
        $LibraryItems = $LibraryItems | Where-Object { $_.Name -notmatch 'Wireless' }
    }
    
    $LibraryItems = $LibraryItems | Sort-Object -Property Name, FullName

    $LibraryItems
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}