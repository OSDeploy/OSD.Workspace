function Get-OSDWSWinPEBuildProfilePath {
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
        Get-OSDWSLibraryPath
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
    $ChildPath = 'winpe-buildprofile'

    Join-Path -Path $(Get-OSDWSCachePath) -ChildPath $ChildPath
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}