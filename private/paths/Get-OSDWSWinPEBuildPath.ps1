function Get-OSDWSWinPEBuildPath {
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
        Get-OSDWSWinPEBuildPath
        Returns the default OSDWorkspace BootMedia Path.

    .NOTES
        David Segura
    #>
    [CmdletBinding()]
    param ()
    #=================================================
    $Error.Clear()
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
    #=================================================
    $ChildPath = 'windows-pe'

    Join-Path -Path $(Get-OSDWSBuildPath) -ChildPath $ChildPath
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}