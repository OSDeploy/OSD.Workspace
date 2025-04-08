function Get-OSDWSLibrarySubmodule {
    <#
    .SYNOPSIS
        Returns the OSDWorkspace Library-GitHub Repositories.

    .NOTES
        David Segura
    #>
    [CmdletBinding()]
    [OutputType([System.IO.FileSystemInfo])]
    param ()
    #=================================================
    $Error.Clear()
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Start"
    #=================================================
    $OSDWSPath = $OSDWorkspace.paths.library_submodule

    $results = foreach ($Path in $OSDWSPath) {
        Get-ChildItem -Path $Path -Directory -Depth 0 -ErrorAction SilentlyContinue | Select-Object -Property * | Where-Object { Test-Path $(Join-Path $_.FullName '.git') }
    }
    
    $results = $results | Sort-Object -Property Name
    $results
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}