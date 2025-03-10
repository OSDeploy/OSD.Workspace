function Remove-OSDWorkspaceRemoteLibrary {
    [CmdletBinding()]
    param (
        # Force the delete of the OSDWorkspace Remote Library
        [System.Management.Automation.SwitchParameter]
        $Force
    )
    #=================================================
    $Error.Clear()
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
    #=================================================
    # Requires Run as Administrator
    $IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $IsAdmin ) {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] This function must be Run as Administrator"
        return
    }
    #=================================================
    # Select an OSDWorkspace Remote Library
    $RemoteLibrariesToDelete = Select-OSDWSGitHubRepo

    if ($RemoteLibrariesToDelete) {
        foreach ($Item in $RemoteLibrariesToDelete) {
            Push-Location "$(Get-OSDWSLibraryRemotePath)"

            $NameToDelete = $Item.Name
            $PathToDelete = $Item.FullName

            Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Removing submodule entry from OSDWorkspace .git/config"
            Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] git submodule deinit -f $PathToDelete"
            git submodule deinit -f "$PathToDelete"

            Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Removing submodule from OSDWorkspace .git/modules"
            Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Remove-Item .git\modules\library-remote\$NameToDelete -Recurse -Force -Verbose"
            Remove-Item ".git\modules\library-remote\$NameToDelete" -Recurse -Force -Verbose

            Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Removing submodule from .gitmodules"
            Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Removing submodule from $PathToDelete"
            Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] git rm -f $PathToDelete"
            git rm -f "$PathToDelete"

            Pop-Location
        }
    }
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}