function Get-OSDWorkspaceMediaPath {
    <#
    .SYNOPSIS
        Returns the OSDWorkspace Media Path.

    .DESCRIPTION
        This function returns the OSDWorkspace Media Path. The default path is C:\OSDWorkspace\Media.

    .INPUTS
        None.

        You cannot pipe input to this cmdlet.

    .OUTPUTS
        System.String

        This function returns the path to the OSDWorkspace Media.

    .EXAMPLE
        Get-OSDWorkspaceMediaPath
        Returns the default OSDWorkspace Media Path.

    .NOTES
        David Segura
    #>
    [CmdletBinding()]
    param ()
    #=================================================
    $Error.Clear()
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
    #=================================================
    $ChildPath = 'media'

    Join-Path -Path $(Get-OSDWorkspacePath) -ChildPath $ChildPath
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}