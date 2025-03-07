function Get-OSDWorkspaceBootMediaPath {
    <#
    .SYNOPSIS
        Returns the OSDWorkspace BootMedia Path.

    .DESCRIPTION
        This function returns the OSDWorkspace BootMedia Path. The default path is C:\OSDWorkspace\BootMedia.

    .INPUTS
        None.

        You cannot pipe input to this cmdlet.

    .OUTPUTS
        System.String

        This function returns the path to the OSDWorkspace BootMedia.

    .EXAMPLE
        Get-OSDWorkspaceBootMediaPath
        Returns the default OSDWorkspace BootMedia Path.

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

    Join-Path -Path $(Get-OSDWorkspaceMediaPath) -ChildPath $ChildPath
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}