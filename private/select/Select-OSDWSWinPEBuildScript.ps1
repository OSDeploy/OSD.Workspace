function Select-OSDWSWinPEBuildScript {
        <#
    .SYNOPSIS
        Selects OSDWorkspace Library Boot Scripts.

    .DESCRIPTION
        This function displays available OSDWorkspace Library Boot Scripts in an Out-GridView and returns the selected scripts.
        Utilizes the Get-OSDWSWinPEBuildScript function to retrieve the scripts.

    .INPUTS
        None.

        You cannot pipe input to this cmdlet.

    .OUTPUTS
        PSObject

        This function returns the selected Library Boot Scripts.

    .EXAMPLE
        Select-OSDWSWinPEBuildScript
        Will display all available Library Boot Scripts and return the selected scripts.

    .NOTES
        David Segura
    #>
    [CmdletBinding()]
    param ()
    #=================================================
    $Error.Clear()
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Start"
    #=================================================
    $results = Get-OSDWSWinPEBuildScript

    if ($results) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Select BootImage and BootMedia Scripts to run during the build (Cancel to skip)"
        $results = $results | Out-GridView -PassThru -Title 'Select BootImage and BootMedia Scripts to run during the build (Cancel to skip)'
    
        return $results
    }
    #=================================================
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}