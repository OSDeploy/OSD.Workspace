function Get-OSDWSWinRESourcePath {
      <#
    .SYNOPSIS
        Returns the OSDWorkspace BootImage Path.

    .DESCRIPTION
        This function returns the OSDWorkspace BootImage Path. The default path is C:\OSDWorkspace\Media-Import\BootImage.

    .INPUTS
        None.

        You cannot pipe input to this cmdlet.

    .OUTPUTS
        System.String

        This function returns the path to the OSDWorkspace BootImage.

    .EXAMPLE
        Get-OSDWSWinRESourcePath
        Returns the default OSDWorkspace BootImage Path.

    .NOTES
        David Segura
    #>
    [CmdletBinding()]
    param ()
    #=================================================
    $Error.Clear()
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
    #=================================================
    $ChildPath = 'windows-re'

    Join-Path -Path $(Get-OSDWSSourcePath) -ChildPath $ChildPath
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}