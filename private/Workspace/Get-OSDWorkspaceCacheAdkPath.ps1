function Get-OSDWorkspaceCacheAdkPath {
    <#
    .SYNOPSIS
        Returns the OSDWorkspace Windows ADK Cache Path. Default is C:\OSDWorkspace\Cache\ADK.

    .DESCRIPTION
        Returns the OSDWorkspace Windows ADK Cache Path. Default is C:\OSDWorkspace\Cache\ADK.

    .NOTES
        David Segura
    #>
    [CmdletBinding()]
    param ()
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
    #=================================================
    $ChildPath = 'ADK'

    Join-Path -Path $(Get-OSDWorkspaceCachePath) -ChildPath $ChildPath
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}