function Select-OSDWSWinPEBuildDriver {
        <#
    .SYNOPSIS
        Selects an OSDWorkspace Library WinPEDriver.

    .DESCRIPTION
        This function displays available OSDWorkspace Library WinPEDrivers in an Out-GridView and returns the selected WinPEDriver(s) object.
        Utilizes the Get-OSDWSWinPEBuildDriver function to retrieve the WinPEDrivers.

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
        Select-OSDWSWinPEBuildDriver
        Will display all available WinPEDrivers and return the selected WinPEDriver object.

    .EXAMPLE
        Select-OSDWSWinPEBuildDriver -Architecture 'amd64'
        Will display all available WinPEDrivers for the architecture 'amd64' and return the selected WinPEDriver object.

    .EXAMPLE
        Select-OSDWSWinPEBuildDriver -BootImage 'ADK'
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
    $Error.Clear()
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Start"
    #=================================================

    if ($Architecture) {
        $results = Get-OSDWSWinPEBuildDriver -Architecture $Architecture
    }
    else {
        $results = Get-OSDWSWinPEBuildDriver
    }

    if (($BootImage -eq 'ADK') -or ($BootImage -eq 'WinPE')) {
        $results = $results | Where-Object { $_.Name -notmatch 'Wireless' }
    }

    # Display the OSDWorkspace WinPEDriver in an Out-GridView to Select
    if ($results) {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Select WinPEDriver to add to this BootImage (Cancel to skip)"
        $results = $results | Out-GridView -PassThru -Title 'Select WinPEDriver to add to this BootImage (Cancel to skip)'

        return $results
    }
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}