function Get-OSDWorkspaceLibraryPath {
    <#
    .SYNOPSIS
        Returns the OSDWorkspace Library Path. Default is C:\OSDWorkspace\Library.

    .DESCRIPTION
        Returns the OSDWorkspace Library Path. Default is C:\OSDWorkspace\Library.

    .NOTES
        David Segura
    #>
    [CmdletBinding()]
    param ()
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
    #=================================================
    $ChildPath = 'Library'

    Join-Path -Path $(Get-OSDWorkspacePath) -ChildPath $ChildPath
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}