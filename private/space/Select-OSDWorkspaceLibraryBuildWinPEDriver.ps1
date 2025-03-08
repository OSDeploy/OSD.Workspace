function Select-OSDWorkspaceLibraryBuildWinPEDriver {
        <#
    .SYNOPSIS
        Selects an OSDWorkspace Library WinPEDriver.

    .DESCRIPTION
        This function displays available OSDWorkspace Library WinPEDrivers in an Out-GridView and returns the selected WinPEDriver(s) object.
        Utilizes the Get-OSDWorkspaceLibraryBuildWinPEDriver function to retrieve the WinPEDrivers.

    .PARAMETER Architecture
        Filters the drivers by architecture (amd64, arm64).

    .PARAMETER BootImage
        Filters the drivers by boot image (ADK, WinPE, WinRE) by excluding Wireless drivers for ADK and WinPE.

    .INPUTS
        None.

        You cannot pipe input to this cmdlet.

    .OUTPUTS
        PSObject

        This function returns the selected WinPEDriver object.

    .EXAMPLE
        Select-OSDWorkspaceLibraryBuildWinPEDriver
        Will display all available WinPEDrivers and return the selected WinPEDriver object.

    .EXAMPLE
        Select-OSDWorkspaceLibraryBuildWinPEDriver -Architecture 'amd64'
        Will display all available WinPEDrivers for the architecture 'amd64' and return the selected WinPEDriver object.

    .EXAMPLE
        Select-OSDWorkspaceLibraryBuildWinPEDriver -BootImage 'ADK'
        Will display all available WinPEDrivers for the boot image 'ADK' and return the selected WinPEDriver object.

    .NOTES
        David Segura
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        # Filters the drivers by architecture (amd64, arm64)
        [ValidateSet('amd64', 'arm64')]
        [System.String]
        $Architecture,

        [Parameter(Mandatory = $false)]
        # Filters the drivers by boot image (ADK, WinPE, WinRE) by excluding Wireless drivers for ADK and WinPE
        [ValidateSet('ADK', 'WinPE', 'WinRE')]
        [System.String]
        $BootImage
    )
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
    $Error.Clear()
    #=================================================

    if ($Architecture) {
        $BuildWinPEDriver = Get-OSDWorkspaceLibraryBuildWinPEDriver -Architecture $Architecture
    }
    else {
        $BuildWinPEDriver = Get-OSDWorkspaceLibraryBuildWinPEDriver
    }

    if (($BootImage -eq 'ADK') -or ($BootImage -eq 'WinPE')) {
        $BuildWinPEDriver = $BuildWinPEDriver | Where-Object { $_.Name -notmatch 'Wireless' }
    }

    # Display the OSDWorkspace WinPEDriver in an Out-GridView to Select
    if ($BuildWinPEDriver) {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Select WinPEDriver to add to this BootImage (Cancel to skip)"
        $BuildWinPEDriver = $BuildWinPEDriver | Out-GridView -PassThru -Title 'Select WinPEDriver to add to this BootImage (Cancel to skip)'
    }

    $BuildWinPEDriver
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}