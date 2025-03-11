function Select-OSDWSWinPEBuild {
    <#
    .SYNOPSIS
        Selects an OSDWorkspace BootMedia.

    .DESCRIPTION
        This function displays available OSDWorkspace BootMedia in an Out-GridView and returns the selected BootMedia object.
        Utilizes the Get-OSDWSWinPEBuild function to retrieve the BootMedia.

    .PARAMETER Architecture
        Filter BootMedia by architecture.

    .INPUTS
        None.

        You cannot pipe input to this cmdlet.

    .OUTPUTS
        PSObject

        This function returns the selected BootMedia object.

    .EXAMPLE
        Select-OSDWSWinPEBuild
        Will display all available BootMedia and return the selected BootMedia in a PSObject.

    .EXAMPLE
        Select-OSDWSWinPEBuild -Architecture 'amd64'
        Will display all available BootMedia for the architecture 'amd64' and return the selected BootMedia object.

    .NOTES
        David Segura
    #>
    [CmdletBinding()]
    param (
        [ValidateSet('amd64', 'arm64')]
        [System.String]
        $Architecture
    )
    #=================================================
    $Error.Clear()
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
    #=================================================

    $results = Get-OSDWSWinPEBuild

    if ($Architecture) {
        $results = $results | Where-Object { $_.Architecture -eq $Architecture }
    }

    if ($results) {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Select a WinPE Build and press OK (Cancel to skip)"
        $results = $results | Out-GridView -Title 'Select a WinPE Build and press OK (Cancel to skip)' -OutputMode Single
    
        return $results
    }
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}