function Get-OSDWorkspaceModuleVersion {
    [CmdletBinding()]
    param ()

    return $MyInvocation.MyCommand.Module.Version
}