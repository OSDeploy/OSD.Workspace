function Update-OSDWorkspaceGitHubRepo {
    <#
    .SYNOPSIS
        Updates a GitHub Repository in C:\OSDWorkspace\Library-GitHub from the GitHub Origin

    .DESCRIPTION
        Updates a GitHub Repository in C:\OSDWorkspace\Library-GitHub from the GitHub Origin

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
        $InputObject = Select-OSDWorkspaceGitHubRepo
        #endregion
        #=================================================
        #region Process foreach
        foreach ($Repository in $InputObject) {
            Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Repository: $($Repository.FullName)"

            if ($Force -eq $true) {
                $Destination = $Repository.FullName
                Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Push-Location `"$Destination`""
                Push-Location "$Destination"

                Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] git fetch --verbose --progress --depth 1 origin"
                git fetch --verbose --progress --depth 1 origin

                Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] git reset --hard origin"
                git reset --hard origin

                #Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] git reset --mixed"
                #git reset --mixed

                Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] git clean -d --force"
                git clean -d --force

                Pop-Location
            }
            else {
                Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] This command will update this Git repository to the latest GitHub commit in the main branch."
                Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Any local content that has been modified or changed will be lost."
                Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] To update this Git Repository, use the -Force switch when running this command."
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