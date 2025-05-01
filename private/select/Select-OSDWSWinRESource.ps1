function Select-OSDWSWinRESource {
    <#
    .SYNOPSIS
        Selects an OSDWorkspace BootImage.

    .DESCRIPTION
        This function displays available OSDWorkspace BootImages in an Out-GridView and return the selected BootImage object.
        Utilizes the Get-OSDWSWinRESource function to retrieve the BootImages.

    .PARAMETER Architecture
        Filter BootImages by architecture.

    .INPUTS
        None.

        You cannot pipe input to this cmdlet.

    .OUTPUTS
        PSOject

        This function returns the selected BootImage object.

    .EXAMPLE
        Select-OSDWSWinRESource
        Will display all available BootImages and return the selected BootImage object.

    .EXAMPLE
        Select-OSDWSWinRESource -Architecture 'amd64'
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
    $Error.Clear()
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Start"
    #=================================================

    $results = Get-OSDWSWinRESource

    if ($Architecture) {
        $results = $results | Where-Object { $_.Architecture -eq $Architecture }
    }

    if ($results) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Select a Windows Recovery Image and press OK (Cancel to skip)"
        $results = $results | Out-GridView -Title 'Select a Windows Recovery Image and press OK (Cancel to skip)' -OutputMode Single

        return $results
    }
    #=================================================
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}