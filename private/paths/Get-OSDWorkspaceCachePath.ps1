function Get-OSDWorkspaceCachePath {
    <#
    .SYNOPSIS
        Returns the OSDWorkspace Cache Path.

    .DESCRIPTION
        This function returns the OSDWorkspace Cache Path. The default path is C:\OSDWorkspace\.cache.

    .INPUTS
        None.

        You cannot pipe input to this cmdlet.

    .OUTPUTS
        System.String

        This function returns the path to the OSDWorkspace Cache.

    .EXAMPLE
        Get-OSDWorkspaceCachePath
        Returns the default OSDWorkspace Cache Path.

    .NOTES
        David Segura
    #>
    [CmdletBinding()]
    param ()
    #=================================================
    $Error.Clear()
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
    #=================================================
    $ChildPath = '.cache'

    Join-Path -Path $(Get-OSDWorkspacePath) -ChildPath $ChildPath
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}