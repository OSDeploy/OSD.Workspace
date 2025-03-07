function Get-OSDWorkspaceGitHubPath {
    <#
    .SYNOPSIS
        Returns the OSDWorkspace Library-GitHub Path.

    .DESCRIPTION
        This function returns the OSDWorkspace Library-GitHub Path. The default path is C:\OSDWorkspace\Library-GitHub.

    .INPUTS
        None.

        You cannot pipe input to this cmdlet.

    .OUTPUTS
        System.String

        This function returns the path to the OSDWorkspace Library-GitHub.

    .EXAMPLE
        Get-OSDWorkspaceGitHubPath
        Returns the default OSDWorkspace Library-GitHub Path.

    .NOTES
        David Segura
    #>
    [CmdletBinding()]
    param ()
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
    #=================================================
    $ChildPath = 'Library-GitHub'

    Join-Path -Path $(Get-OSDWorkspacePath) -ChildPath $ChildPath
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}