function Update-OSDWorkspaceSubmodule {
    <#
    .SYNOPSIS
        Updates a GitHub Repository in C:\OSDWorkspace\Library-GitHub from the GitHub Origin

    .DESCRIPTION
        This function updates ALL GitHub repositories in the OSDWorkspace Library-GitHub directory.
        The function will update this Git repository to the latest GitHub commit in the main branch.
        It performs a fetch and clean operation to ensure the repository is up to date and free of untracked files.
        If you have not cloned the repository, use Add-OSDWorkspaceSubmodule to clone it.

    .PARAMETER Force
        The -Force switch is Required to update the GitHub repository.
        This will overwrite any local changes to the repository.

    .INPUTS
        None.

        You cannot pipe input to this cmdlet.

    .OUTPUTS
        None.

        This function does not return any output.

    .EXAMPLE
        Update-OSDWorkspaceSubmodule -Force
        Updates all GitHub repositories in the OSDWorkspace Library-GitHub directory to the latest GitHub commit in the main branch.

    .LINK
        https://github.com/OSDeploy/OSD.Workspace/blob/main/docs/Update-OSDWorkspaceSubmodule.md

    .NOTES
        David Segura
    #>
    [CmdletBinding()]
    param (
        # Force the update of the Git Repository, overwriting all content
        [System.Management.Automation.SwitchParameter]
        $Force
    )

    begin {
        #=================================================
        $Error.Clear()
        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
        Initialize-OSDWorkspace
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
        $RepositoryPath = $OSDWorkspace.Path
        Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] OSDWorkspace: $RepositoryPath"

        if ($Force -eq $true) {
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Push-Location `"$RepositoryPath`""
            Push-Location "$RepositoryPath"

            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] git submodule update --remote --merge"
            git submodule update --remote --merge

            # Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] git commit -m `"Add submodule Update-OSDWorkspaceSubmodule`""
            # git commit -m "Add submodule Update-OSDWorkspaceSubmodule"

            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Pop-Location"
            Pop-Location
        }
        else {
            Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] This command will update this Git repository to the latest GitHub commit in the main branch using git fetch."
            Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Use the -Force switch when running this command."
            Write-Host
        }
        #=================================================
    }
    
    end {
        #=================================================
        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
        #=================================================
    }
}