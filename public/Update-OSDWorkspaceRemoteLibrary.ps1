function Update-OSDWorkspaceRemoteLibrary {
    <#
    .SYNOPSIS
        Updates a GitHub Repository in C:\OSDWorkspace\Library-GitHub from the GitHub Origin

    .DESCRIPTION
        This function updates ALL GitHub repositories in the OSDWorkspace Library-GitHub directory.
        The function will update this Git repository to the latest GitHub commit in the main branch.
        It performs a fetch and clean operation to ensure the repository is up to date and free of untracked files.
        If you have not cloned the repository, use Add-OSDWorkspaceRemoteLibrary to clone it.

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
        Update-OSDWorkspaceRemoteLibrary -Force
        Updates all GitHub repositories in the OSDWorkspace Library-GitHub directory to the latest GitHub commit in the main branch.

    .LINK
        https://github.com/OSDeploy/OSD.Workspace/blob/main/docs/Update-OSDWorkspaceRemoteLibrary.md

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
        foreach ($Repository in $InputObject) {
            Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Repository: $($Repository.FullName)"

            if ($Force -eq $true) {
                $RepositoryPath = $Repository.FullName
                Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Push-Location `"$RepositoryPath`""
                Push-Location "$RepositoryPath"

                Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] git fetch --verbose --progress --depth 1 origin"
                git fetch --verbose --progress --depth 1 origin

                <#
                Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] git reset --hard origin"
                git reset --hard origin

                #Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] git reset --mixed"
                #git reset --mixed

                Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] git clean -d --force"
                git clean -d --force
                #>
                Pop-Location
            }
            else {
                Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] This command will update this Git repository to the latest GitHub commit in the main branch using git fetch."
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