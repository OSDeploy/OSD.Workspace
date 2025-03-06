function Get-OSDWorkspaceBootImagePath {
      <#
    .SYNOPSIS
        Returns the OSDWorkspace BootImage Path.

    .DESCRIPTION
        This function returns the OSDWorkspace BootImage Path. The default path is C:\OSDWorkspace\BootImage.

    .INPUTS
        None.

        You cannot pipe input to this cmdlet.

    .OUTPUTS
        System.String

        This function returns the path to the OSDWorkspace BootImage.

    .EXAMPLE
        Get-OSDWorkspaceBootImagePath
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
    $ChildPath = 'BootImage'

    Join-Path -Path $(Get-OSDWorkspacePath) -ChildPath $ChildPath
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}