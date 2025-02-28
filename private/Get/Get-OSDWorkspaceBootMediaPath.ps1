function Get-OSDWorkspaceBootMediaPath {
    <#
    .SYNOPSIS
        Returns the OSDWorkspace BootMedia Path. Default is C:\OSDWorkspace\BootMedia.

    .DESCRIPTION
        Returns the OSDWorkspace BootMedia Path. Default is C:\OSDWorkspace\BootMedia.

    .NOTES
        David Segura
    #>
    [CmdletBinding()]
    param ()
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
    $Error.Clear()
    #=================================================
    $ChildPath = 'BootMedia'

    Join-Path -Path $(Get-OSDWorkspacePath) -ChildPath $ChildPath
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}