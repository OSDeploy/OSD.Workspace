function Get-OSDWorkspaceGitHubPath {
    <#
    .SYNOPSIS
        Returns the OSDWorkspace Library-GitHub Path. Default is C:\OSDWorkspace\Library-GitHub.

    .DESCRIPTION
        Returns the OSDWorkspace Library-GitHub Path. Default is C:\OSDWorkspace\Library-GitHub.

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