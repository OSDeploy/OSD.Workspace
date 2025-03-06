function Get-OSDWorkspaceBootImagePath {
    <#
    .SYNOPSIS
        Returns the OSDWorkspace BootImage Path. Default is C:\OSDWorkspace\BootImage.

    .DESCRIPTION
        Returns the OSDWorkspace BootImage Path. Default is C:\OSDWorkspace\BootImage.

    .NOTES
        David Segura
    #>
    [CmdletBinding()]
    param ()
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
    $Error.Clear()
    #=================================================
    $ChildPath = 'BootImage'

    Join-Path -Path $(Get-OSDWorkspacePath) -ChildPath $ChildPath
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}