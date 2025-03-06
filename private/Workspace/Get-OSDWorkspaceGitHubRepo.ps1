function Get-OSDWorkspaceGitHubRepo {
    <#
    .SYNOPSIS
        Returns the OSDWorkspace Library-GitHub Repositories.

    .DESCRIPTION
        Returns the OSDWorkspace Library-GitHub Repositories.

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
    $OSDWorkspacePath = Get-OSDWorkspaceGitHubPath

    $Results = foreach ($Path in $OSDWorkspacePath) {
        Get-ChildItem -Path $Path -Directory -Depth 0 -ErrorAction SilentlyContinue | Select-Object -Property * | Where-Object { Test-Path $(Join-Path $_.FullName '.git') }
    }

    $Results
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}