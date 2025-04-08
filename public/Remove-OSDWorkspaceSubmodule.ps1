function Remove-OSDWorkspaceSubmodule {
    <#
    .SYNOPSIS
        Remove a submodule from OSDWorkspace

    .DESCRIPTION
        Remove a submodule from OSDWorkspace by removing the submodule entry from .gitmodules and deleting the submodule Directory.
        Requires the -Force switch to delete the submodule.

    .NOTES
        David Segura
    #>
    [CmdletBinding()]
    param (
        # Force the deletion of the submodule from OSDWorkspace
        [System.Management.Automation.SwitchParameter]
        $Force
    )

    begin {
        #=================================================
        $Error.Clear()
        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Start"
        Initialize-OSDWorkspace
        #=================================================
        # Requires Run as Administrator
        $IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        if (-not $IsAdmin ) {
            Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] This function must be Run as Administrator"
            return
        }
        #=================================================
    }

    process {
        #=================================================
        #region Get InputObject
        $InputObject = @()
        $InputObject = Select-OSDWSSharedLibrary
        #endregion
        #=================================================
        #region Process foreach
        
        $OSDWorkspacePath = Get-OSDWorkspacePath

        foreach ($Repository in $InputObject) {
            Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Repository: $($Repository.FullName)"

            if ($Force -eq $true) {
                Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Push-Location `"$OSDWorkspacePath`""
                Push-Location $OSDWorkspacePath

                $RepositoryName = $Repository.Name
                Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] RepositoryName: $RepositoryName"

                $RepositoryPathToDelete = "submodules/$RepositoryName"
                Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] RepositoryPathToDelete: $RepositoryPathToDelete"

                Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Removing submodule entry from OSDWorkspace .git/config"
                Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] git submodule deinit --force $RepositoryPathToDelete"
                git submodule deinit --force "$RepositoryPathToDelete"

                $RemoveItemPath = ".git\modules\submodules\$RepositoryName"
                Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] RemoveItemPath: $RemoveItemPath"
                if (Test-Path $RemoveItemPath) {
                    Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Removing submodule from OSDWorkspace .git/modules"
                    Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Remove-Item $RemoveItemPath -Recurse -Force"
                    Remove-Item $RemoveItemPath -Recurse -Force -ErrorAction SilentlyContinue
                }

                Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Removing submodule from .gitmodules"
                Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Deleting submodule from $RepositoryPathToDelete"
                Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] git rm --force $RepositoryPathToDelete"
                git rm --force "$RepositoryPathToDelete"

                Pop-Location
            }
            else {
                Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] This command will permanently delete this repository from OSDWorkspace."
                Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Use the -Force switch when running this command."
                Write-Host
            }
        }
        #endregion
        #=================================================
    }
    
    end {
        #=================================================
        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] End"
        #=================================================
    }
}