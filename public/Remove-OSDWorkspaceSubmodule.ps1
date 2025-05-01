function Remove-OSDWorkspaceSubmodule {
    <#
    .SYNOPSIS
        Removes one or more Git submodules from the OSDWorkspace repository.

    .DESCRIPTION
        The Remove-OSDWorkspaceSubmodule function removes selected Git submodules from the OSDWorkspace repository 
        (typically located at C:\OSDWorkspace\submodules).
        
        This function performs the following operations:
        1. Validates administrator privileges
        2. Prompts for selection of submodules to remove using Select-OSDWSSharedLibrary
        3. For each selected submodule:
           a. Removes the submodule entry from .git/config using 'git submodule deinit'
           b. Removes the submodule's files from .git/modules directory
           c. Removes the submodule entry from .gitmodules and deletes the submodule directory using 'git rm'
        
        The -Force parameter is required to perform the deletion operation as a safety measure.

    .PARAMETER Force
        Required switch parameter to confirm that you want to delete the selected submodules.
        This is a safety measure to prevent accidental deletion of submodules.

    .EXAMPLE
        Remove-OSDWorkspaceSubmodule -Force
        
        Prompts for selection of submodules and then removes the selected submodules from the OSDWorkspace repository.

    .EXAMPLE
        Remove-OSDWorkspaceSubmodule -Force -Verbose
        
        Removes selected submodules with detailed output showing each step of the process.

    .OUTPUTS
        None. This function does not generate any output objects.

    .NOTES
        Author: David Segura
        Version: 1.0
        Date: April 2025
        
        Prerequisites:
            - Git for Windows must be installed and available in the system's PATH. (https://gitforwindows.org/)
            - PowerShell 7.5 or higher is recommended.
            - The script must be run with administrator privileges.
            - The target OSDWorkspace repository must have submodules already added.
        
        This function permanently removes selected submodules from the OSDWorkspace repository.
        This is a destructive operation that cannot be undone except by restoring from a backup.
        
        For more information about Git submodules, see:
            https://git-scm.com/docs/git-submodule
            https://git-scm.com/book/en/v2/Git-Tools-Submodules
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
        Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Start"
        Initialize-OSDWorkspace
        #=================================================
        # Requires Run as Administrator
        $IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        if (-not $IsAdmin ) {
            Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] This function must be Run as Administrator"
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
            Write-Host -ForegroundColor DarkCyan "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Repository: $($Repository.FullName)"

            if ($Force -eq $true) {
                Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Push-Location `"$OSDWorkspacePath`""
                Push-Location $OSDWorkspacePath

                $RepositoryName = $Repository.Name
                Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] RepositoryName: $RepositoryName"

                $RepositoryPathToDelete = "submodules/$RepositoryName"
                Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] RepositoryPathToDelete: $RepositoryPathToDelete"

                Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Removing submodule entry from OSDWorkspace .git/config"
                Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] git submodule deinit --force $RepositoryPathToDelete"
                git submodule deinit --force "$RepositoryPathToDelete"

                $RemoveItemPath = ".git\modules\submodules\$RepositoryName"
                Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] RemoveItemPath: $RemoveItemPath"
                if (Test-Path $RemoveItemPath) {
                    Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Removing submodule from OSDWorkspace .git/modules"
                    Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Remove-Item $RemoveItemPath -Recurse -Force"
                    Remove-Item $RemoveItemPath -Recurse -Force -ErrorAction SilentlyContinue
                }

                Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Removing submodule from .gitmodules"
                Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Deleting submodule from $RepositoryPathToDelete"
                Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] git rm --force $RepositoryPathToDelete"
                git rm --force "$RepositoryPathToDelete"

                Pop-Location
            }
            else {
                Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] This command will permanently delete this repository from OSDWorkspace."
                Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Use the -Force switch when running this command."
                Write-Host
            }
        }
        #endregion
        #=================================================
    }
    
    end {
        #=================================================
        Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] End"
        #=================================================
    }
}