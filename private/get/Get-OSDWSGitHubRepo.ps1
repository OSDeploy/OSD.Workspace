function Get-OSDWSGitHubRepo {
     <#
    .SYNOPSIS
        Returns the OSDWorkspace Library-GitHub Repositories.

    .DESCRIPTION
        This function returns the OSDWorkspace Library-GitHub Repositories.

    .INPUTS
        None.

        You cannot pipe input to this cmdlet.

    .OUTPUTS
        System.IO.FileSystemInfo

        This function returns the repositories in the OSDWorkspace Library-GitHub.

    .EXAMPLE
        Get-OSDWSGitHubRepo
        Returns the repositories in the OSDWorkspace Library-GitHub.

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
    $OSDWorkspacePath = Get-OSDWSLibraryRemotePath

    $Results = foreach ($Path in $OSDWorkspacePath) {
        Get-ChildItem -Path $Path -Directory -Depth 0 -ErrorAction SilentlyContinue | Select-Object -Property * | Where-Object { Test-Path $(Join-Path $_.FullName '.git') }
    }

    $Results
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}