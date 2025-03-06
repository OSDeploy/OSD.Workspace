function Select-OSDWorkspaceBootMedia {
    <#
    .SYNOPSIS
        Selects an OSDWorkspace BootMedia.

    .DESCRIPTION
        This function displays available OSDWorkspace BootMedia in an Out-GridView and returns the selected BootMedia object.
        Utilizes the Get-OSDWorkspaceBootMedia function to retrieve the BootMedia.

    .PARAMETER Architecture
        Filter BootMedia by architecture.

    .INPUTS
        None.

        You cannot pipe input to this cmdlet.

    .OUTPUTS
        PSObject

        This function returns the selected BootMedia object.

    .EXAMPLE
        Select-OSDWorkspaceBootMedia
        Will display all available BootMedia and return the selected BootMedia in a PSObject.

    .EXAMPLE
        Select-OSDWorkspaceBootMedia -Architecture 'amd64'
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
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
    $Error.Clear()
    #=================================================

    $BootMedia = Get-OSDWorkspaceBootMedia

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