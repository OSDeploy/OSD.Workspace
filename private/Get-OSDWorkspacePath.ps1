function Get-OSDWorkspacePath {
    <#
    .SYNOPSIS
        Returns the OSDWorkspace Path. Default is C:\OSDWorkspace.

    .NOTES
        David Segura
    #>
    [CmdletBinding()]
    param ()
    #=================================================
    $Error.Clear()
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
    #=================================================
    # Path will always default to C:\OSDWorkspace
    $OSDWorkspacePath = $OSDWorkspace.path
    if (-not $OSDWorkspacePath) {
        $OSDWorkspacePath = 'C:\OSDWorkspace'
    }

    return $OSDWorkspacePath
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}