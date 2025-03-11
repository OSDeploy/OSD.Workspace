function Get-OSDWSAdkVersionsPath {
    <#
    .SYNOPSIS
        Returns the OSDWorkspace Windows ADK Cache Path.

    .DESCRIPTION
        This function returns the OSDWorkspace Windows ADK Cache Path. The default path is C:\OSDWorkspace\cache\ADK.

    .INPUTS
        None.

        You cannot pipe input to this cmdlet.

    .OUTPUTS
        System.String

        This function returns the path to the OSDWorkspace Windows ADK Cache.

    .EXAMPLE
        Get-OSDWSAdkVersionsPath
        Returns the default OSDWorkspace Windows ADK Cache Path.

    .NOTES
        David Segura
    #>
    [CmdletBinding()]
    param ()
    #=================================================
    $Error.Clear()
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
    #=================================================
    $ChildPath = 'adk-versions'

    Join-Path -Path $(Get-OSDWSCachePath) -ChildPath $ChildPath
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}