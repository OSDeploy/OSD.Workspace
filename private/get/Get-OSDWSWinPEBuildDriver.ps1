function Get-OSDWSWinPEBuildDriver {
    <#
    .SYNOPSIS
        Returns available OSDWorkspace Library WinPEDriver(s).

    .DESCRIPTION
        This function returns available OSDWorkspace Library and Library-GitHub WinPEDriver(s).
        Utilizes the Get-OSDWSWinRESource and Get-OSDWSLibraryRemotePath functions to retrieve the WinPEDriver Path(s)

    .INPUTS
        None.

        You cannot pipe input to this cmdlet.

    .OUTPUTS
        System.Array

        This function returns the available boot drivers in the OSDWorkspace Library.

    .EXAMPLE
        Get-OSDWSWinPEBuildDriver
        Returns the boot drivers in the OSDWorkspace Library.

    .EXAMPLE
        Get-OSDWSWinPEBuildDriver -Architecture amd64
        Returns the boot drivers in the OSDWorkspace Library filtered by architecture.

    .EXAMPLE
        Get-OSDWSWinPEBuildDriver -BootImage ADK
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

    # Get the OSDWorkspace Library Subfolders
    $PrivateLibrary = Get-OSDWSLibraryPath
    foreach ($Subfolder in $PrivateLibrary) {
        $LibraryPaths += Get-ChildItem -Path $Subfolder -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName
    }

    # Get the OSDWorkspace Public Subfolders
    $PublicLibrary = Get-OSDWSLibraryRemotePath
    foreach ($Subfolder in $PublicLibrary) {
        $LibraryPaths += Get-ChildItem -Path $Subfolder -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName
    }
    
    $LibraryItems = @()
    $LibraryItems = foreach ($LibraryPath in $LibraryPaths) {
        Get-ChildItem -Path @("$LibraryPath\WinPE-Driver\*\*") -ErrorAction SilentlyContinue | `
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