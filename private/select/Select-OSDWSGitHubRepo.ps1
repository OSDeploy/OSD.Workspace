function Select-OSDWSRemoteLibrary {
       <#
    .SYNOPSIS
        Selects an OSDWorkspace Library GitHub Reposiotry.

    .DESCRIPTION
        This function displays available OSDWorkspace Library GitHub Repositories in an Out-GridView and returns the selected BootMedia object.
        Utilizes the Get-OSDWSLibrarySubmodule function to retrieve the available HitHub Repositories.

    .INPUTS
        None.

        You cannot pipe input to this cmdlet.

    .OUTPUTS
        PSObject

        This function returns the selected GitHub Repository in a PSobject.

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
    [OutputType([System.IO.FileSystemInfo])]
    param ()
    #=================================================
    $Error.Clear()
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
    #=================================================
    $results = Get-OSDWSLibrarySubmodule | Select-Object -Property Name, FullName | Sort-Object -Property Name, FullName

    if ($results) {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Select an OSDWorkspace Repository (Cancel to skip)"
        $results = $results | Out-GridView -PassThru -Title 'Select an OSDWorkspace Repository (Cancel to skip)'
    
        return $results
    }
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}