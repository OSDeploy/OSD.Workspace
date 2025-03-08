function Get-OSDWorkspaceImportPath {
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
        Get-OSDWorkspaceBuildPath
        Returns the default OSDWorkspace Media Path.

    .NOTES
        David Segura
    #>
    [CmdletBinding()]
    param ()
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
    $Error.Clear()
    #=================================================
    $ChildPath = '.import'

    Join-Path -Path $(Get-OSDWorkspacePath) -ChildPath $ChildPath
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}