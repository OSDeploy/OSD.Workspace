function Update-OSDWorkspaceSubmodule {
    <#
    .SYNOPSIS
        Updates all submodules in the OSDWorkspace.

    .DESCRIPTION
        This function updates all submodules in the OSDWorkspace C:\OSDWorkspace\Submodules directory.
        Performs a 'git submodule update --remote --merge' to update the submodules to the latest commit in the main branch.
        If you have not added the repository as a Submodule, use Add-OSDWorkspaceSubmodule.

    .EXAMPLE
        Update-OSDWorkspaceSubmodule -Force
        Updates all GitHub repositories in the OSDWorkspace Library-GitHub directory to the latest GitHub commit in the main branch.

    .NOTES
        David Segura
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