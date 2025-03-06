function Select-OSDWorkspaceLibraryBootDriver {
        <#
    .SYNOPSIS
        Selects an OSDWorkspace Library BootDriver.

    .DESCRIPTION
        This function displays available OSDWorkspace Library BootDrivers in an Out-GridView and returns the selected BootDriver(s) object.
        Utilizes the Get-OSDWorkspaceLibraryBootDriver function to retrieve the BootDrivers.

    .PARAMETER Architecture
        Filters the drivers by architecture (amd64, arm64).

    .PARAMETER BootImage
        Filters the drivers by boot image (ADK, WinPE, WinRE) by excluding Wireless drivers for ADK and WinPE.

    .INPUTS
        None.

        You cannot pipe input to this cmdlet.

    .OUTPUTS
        PSObject

        This function returns the selected BootDriver object.

    .EXAMPLE
        Select-OSDWorkspaceLibraryBootDriver
        Will display all available BootDrivers and return the selected BootDriver object.

    .EXAMPLE
        Select-OSDWorkspaceLibraryBootDriver -Architecture 'amd64'
        Will display all available BootDrivers for the architecture 'amd64' and return the selected BootDriver object.

    .EXAMPLE
        Select-OSDWorkspaceLibraryBootDriver -BootImage 'ADK'
        Will display all available BootDrivers for the boot image 'ADK' and return the selected BootDriver object.

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
        $BootDriver = Get-OSDWorkspaceLibraryBootDriver -Architecture $Architecture
    }
    else {
        $BootDriver = Get-OSDWorkspaceLibraryBootDriver
    }

    if (($BootImage -eq 'ADK') -or ($BootImage -eq 'WinPE')) {
        $BootDriver = $BootDriver | Where-Object { $_.Name -notmatch 'Wireless' }
    }

    # Display the OSDWorkspace BootDriver in an Out-GridView to Select
    if ($BootDriver) {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Select BootDriver to add to this BootImage (Cancel to skip)"
        $BootDriver = $BootDriver | Out-GridView -PassThru -Title 'Select BootDriver to add to this BootImage (Cancel to skip)'
    }

    $BootDriver
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}