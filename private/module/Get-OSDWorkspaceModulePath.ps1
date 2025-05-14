function Get-OSDWorkspaceModulePath {
    [CmdletBinding()]
    param ()

    return $MyInvocation.MyCommand.Module.ModuleBase
}