function Select-OSDWorkspaceLibraryBootDriver {
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