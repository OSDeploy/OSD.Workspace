function Update-OSDWorkspaceSubmodule {
    <#
    .SYNOPSIS
        Updates all submodules in the OSDWorkspace repository to their latest commits.

    .DESCRIPTION
        The Update-OSDWorkspaceSubmodule function updates all Git submodules in the OSDWorkspace repository
        (typically located at C:\OSDWorkspace\submodules) to their latest commits from the remote repositories.
        
        This function performs the following operations:
        1. Validates administrator privileges
        2. Navigates to the OSDWorkspace repository root
        3. Executes 'git submodule update --remote --merge' to update all submodules to the latest commits
        4. Returns to the original location
        
        The -Force parameter is required to perform the update operation to prevent accidental updates.
        
        If you have not added a repository as a submodule yet, use Add-OSDWorkspaceSubmodule first.

    .PARAMETER Force
        Required switch parameter to confirm that you want to update all submodules.
        This is a safety measure to prevent accidentally updating submodules.

    .EXAMPLE
        Update-OSDWorkspaceSubmodule -Force
        
        Updates all submodules in the OSDWorkspace repository to their latest commits.

    .EXAMPLE
        Update-OSDWorkspaceSubmodule -Force -Verbose
        
        Updates all submodules with detailed output showing each step of the process.

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
        
        This function modifies existing submodules by updating them to the latest commit from their respective repositories.
        
        For more information about Git submodules, see:
            https://git-scm.com/docs/git-submodule
            https://git-scm.com/book/en/v2/Git-Tools-Submodules
    #>


    [CmdletBinding()]
    param (
        # Force Update all Submodules in the OSDWorkspace
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
        $RepositoryPath = $OSDWorkspace.Path
        Write-Host -ForegroundColor DarkCyan "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] OSDWorkspace: $RepositoryPath"

        if ($Force -eq $true) {
            Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Push-Location `"$RepositoryPath`""
            Push-Location "$RepositoryPath"

            Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] git submodule update --remote --merge"
            git submodule update --remote --merge

            # Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] git commit -m `"Add submodule Update-OSDWorkspaceSubmodule`""
            # git commit -m "Add submodule Update-OSDWorkspaceSubmodule"

            Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Pop-Location"
            Pop-Location
        }
        else {
            Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] This command will update this Git repository to the latest GitHub commit in the main branch using git fetch."
            Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Use the -Force switch when running this command."
            Write-Host
        }
        #=================================================
    }
    
    end {
        #=================================================
        Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] End"
        #=================================================
    }
}