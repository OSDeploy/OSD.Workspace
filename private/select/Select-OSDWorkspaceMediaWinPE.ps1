function Select-OSDWorkspaceMediaWinPE {
    <#
    .SYNOPSIS
        Selects an OSDWorkspace BootMedia.

    .DESCRIPTION
        This function displays available OSDWorkspace BootMedia in an Out-GridView and returns the selected BootMedia object.
        Utilizes the Get-OSDWorkspaceMediaWinPE function to retrieve the BootMedia.

    .PARAMETER Architecture
        Filter BootMedia by architecture.

    .INPUTS
        None.

        You cannot pipe input to this cmdlet.

    .OUTPUTS
        PSObject

        This function returns the selected BootMedia object.

    .EXAMPLE
        Select-OSDWorkspaceMediaWinPE
        Will display all available BootMedia and return the selected BootMedia in a PSObject.

    .EXAMPLE
        Select-OSDWorkspaceMediaWinPE -Architecture 'amd64'
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

    $BootMedia = Get-OSDWorkspaceMediaWinPE

    if ($Architecture) {
        $BootMedia = $BootMedia | Where-Object { $_.Architecture -eq $Architecture }
    }

    if ($BootMedia) {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Select a BootMedia and press OK (Cancel to skip)"
        $BootMedia = $BootMedia | Out-GridView -Title 'Select a BootMedia and press OK (Cancel to skip)' -OutputMode Single
    }
    $BootMedia
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}