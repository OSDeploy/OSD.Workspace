function Get-OSDWorkspaceOSImagePath {
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
        Get-OSDWorkspaceREImagePath
        Returns the default OSDWorkspace BootImage Path.

    .NOTES
        David Segura
    #>
    [CmdletBinding()]
    param ()
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
    $Error.Clear()
    #=================================================
    $ChildPath = 'os-image'

    Join-Path -Path $(Get-OSDWorkspaceImportPath) -ChildPath $ChildPath
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}