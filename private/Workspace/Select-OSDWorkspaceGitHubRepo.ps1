function Select-OSDWorkspaceGitHubRepo {
       <#
    .SYNOPSIS
        Selects an OSDWorkspace Library GitHub Reposiotry.

    .DESCRIPTION
        This function displays available OSDWorkspace Library GitHub Repositories in an Out-GridView and returns the selected BootMedia object.
        Utilizes the Get-OSDWorkspaceGitHubRepo function to retrieve the available HitHub Repositories.

    .INPUTS
        None.

        You cannot pipe input to this cmdlet.

    .OUTPUTS
        PSObject

        This function returns the selected GitHub Repository in a PSobject.

    .EXAMPLE
        Select-OSDWorkspaceWinPE
        Will display all available BootMedia and return the selected BootMedia in a PSObject.

    .EXAMPLE
        Select-OSDWorkspaceWinPE -Architecture 'amd64'
        Will display all available BootMedia for the architecture 'amd64' and return the selected BootMedia object.

    .NOTES
        David Segura
    #>
    [CmdletBinding()]
    [OutputType([System.IO.FileSystemInfo])]
    param ()
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
    $Error.Clear()
    #=================================================
    $OSDWorkspaceGitRepository = Get-OSDWorkspaceGitHubRepo | Select-Object -Property Name, FullName | Sort-Object -Property Name, FullName

    if ($OSDWorkspaceGitRepository) {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Select an OSDWorkspace Repository (Cancel to skip)"
        $OSDWorkspaceGitRepository = $OSDWorkspaceGitRepository | Out-GridView -PassThru -Title 'Select an OSDWorkspace Repository (Cancel to skip)'
    
        $OSDWorkspaceGitRepository
    }
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}