function Get-OSDWSDocsPath {
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
        Get-OSDWSDocsPath
        Returns the OSDWorkspace Library Path.

    .NOTES
        David Segura
    #>
    [CmdletBinding()]
    param ()
    #=================================================
    $Error.Clear()
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
    #=================================================
    $ChildPath = 'docs'

    Join-Path -Path $(Get-OSDWorkspacePath) -ChildPath $ChildPath
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}