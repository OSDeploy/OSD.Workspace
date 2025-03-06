function Get-OSDWorkspaceCachePath {
    <#
    .SYNOPSIS
        Returns the OSDWorkspace Cache Path. Default is C:\OSDWorkspace\Cache.

    .DESCRIPTION
        Returns the OSDWorkspace Cache Path. Default is C:\OSDWorkspace\Cache.

    .NOTES
        David Segura
    #>
    [CmdletBinding()]
    param ()
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
    #=================================================
    $ChildPath = 'Cache'

    Join-Path -Path $(Get-OSDWorkspacePath) -ChildPath $ChildPath
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}