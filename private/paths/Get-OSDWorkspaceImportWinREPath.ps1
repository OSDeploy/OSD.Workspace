function Get-OSDWorkspaceImportWinREPath {
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
        Get-OSDWorkspaceImportWinREPath
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
    $ChildPath = 'WinRE'

    Join-Path -Path $(Get-OSDWorkspaceImportPath) -ChildPath $ChildPath
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}