function Remove-OSDWorkspaceRemoteLibrary {
    [CmdletBinding()]
    param (
        # Force the delete of the OSDWorkspace Remote Library
        [System.Management.Automation.SwitchParameter]
        $Force
    )

    begin {
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
    }

    process {
        #=================================================
        #region Get InputObject
        $InputObject = @()
        $InputObject = Select-OSDWSRemoteLibrary
        #endregion
        #=================================================
        #region Process foreach
        
        $OSDWorkspacePath = Get-OSDWorkspacePath

        foreach ($Repository in $InputObject) {
            Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Repository: $($Repository.FullName)"

            if ($Force -eq $true) {
                Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Push-Location `"$OSDWorkspacePath`""
                Push-Location $OSDWorkspacePath

                $RepositoryName = $Item.Name
                Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] RepositoryName: $RepositoryName"

                $RepositoryPathToDelete = "library-remote/$RepositoryName"
                Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] RepositoryPathToDelete: $RepositoryPathToDelete"

                Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Removing submodule entry from OSDWorkspace .git/config"
                Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] git submodule deinit --force $RepositoryPathToDelete"
                git submodule deinit --force "$RepositoryPathToDelete"

                $DeletePath = ".git\modules\library-remote\$RepositoryName"
                if (Test-Path $DeletePath) {
                    Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Removing submodule from OSDWorkspace .git/modules"
                    Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Remove-Item .git\modules\library-remote\$RepositoryName -Recurse -Force"
                    Remove-Item ".git\modules\library-remote\$RepositoryName" -Recurse -Force -ErrorAction SilentlyContinue
                }

                Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Removing submodule from .gitmodules"
                Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Removing submodule from $RepositoryPathToDelete"
                Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] git rm --force $RepositoryPathToDelete"
                git rm --force "$RepositoryPathToDelete"

                Pop-Location
            }
            else {
                Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] This command will permanently delete this repository from OSDWorkspace."
                Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Use the -Force switch when running this command."
                Write-Host
            }
        }
        #endregion
        #=================================================
    }
    
    end {
        #=================================================
        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
        #=================================================
    }
}