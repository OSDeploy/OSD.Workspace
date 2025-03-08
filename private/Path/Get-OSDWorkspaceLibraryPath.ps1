function Get-OSDWorkspaceLibraryPath {
    <#
    .SYNOPSIS
        Returns the OSDWorkspace Library Path.

    .DESCRIPTION
        This function returns the OSDWorkspace Library Path. Default is C:\OSDWorkspace\Library.

    .INPUTS
        None.

        You cannot pipe input to this cmdlet.

    .OUTPUTS
        System.String

        This function returns the OSDWorkspace Library Path as a string.

    .EXAMPLE
        Get-OSDWorkspaceLibraryPath
        Returns the OSDWorkspace Library Path.

    .NOTES
        David Segura
    #>
    [CmdletBinding()]
    param ()
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
    #=================================================
    $ChildPath = 'library'

    Join-Path -Path $(Get-OSDWorkspacePath) -ChildPath $ChildPath
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}