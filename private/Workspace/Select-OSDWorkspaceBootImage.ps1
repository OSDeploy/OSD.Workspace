function Select-OSDWorkspaceBootImage {
    <#
    .SYNOPSIS
        Selects an OSDWorkspace BootImage.

    .DESCRIPTION
        This function displays available OSDWorkspace BootImages in an Out-GridView and return the selected BootImage object.
        Utilizes the Get-OSDWorkspaceBootImage function to retrieve the BootImages.

    .PARAMETER Architecture
        Filter BootImages by architecture.

    .INPUTS
        None.

        You cannot pipe input to this cmdlet.

    .OUTPUTS
        PSOject

        This function returns the selected BootImage object.

    .EXAMPLE
        Select-OSDWorkspaceBootImage
        Will display all available BootImages and return the selected BootImage object.

    .EXAMPLE
        Select-OSDWorkspaceBootImage -Architecture 'amd64'
        Will display all available BootImages for the architecture 'amd64' and return the selected BootImage object.

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

    $BootImage = Get-OSDWorkspaceBootImage

    if ($Architecture) {
        $BootImage = $BootImage | Where-Object { $_.Architecture -eq $Architecture }
    }

    if ($BootImage) {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Select a BootImage and press OK (Cancel to skip)"
        $BootImage = $BootImage | Out-GridView -Title 'Select a BootImage and press OK (Cancel to skip)' -OutputMode Single
    }
    $BootImage
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}