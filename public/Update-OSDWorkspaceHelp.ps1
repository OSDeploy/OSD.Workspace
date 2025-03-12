function Update-OSDWorkspaceHelp {
    [CmdletBinding()]
    param (
        # Force the update of OSDWorkspace PowerShell-Help
        [System.Management.Automation.SwitchParameter]
        $Force
    )
    #=================================================
    $Error.Clear()
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
    Initialize-OSDWorkspace
    #=================================================
    # Test Run as Administrator
    $IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    #=================================================
    # PlatyPS
    if (Get-Module platyPS -ListAvailable -ErrorAction SilentlyContinue) {
        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] PowerShell Module platyPS is installed"
    }
    else {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] PowerShell Module platyPS is not installed"
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Use PowerShell to resolve this issue:"
        Write-Host 'Install-Module -Name platyPS -Scope CurrentUser'
        Write-Host 'Import-Module platyPS'
        return
    }
    #=================================================
    # Create PowerShell-Help
    $PowerShellHelpPath = $OSDWorkspace.paths.powershell_help

    if (-not (Test-Path $PowerShellHelpPath)) {
        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Creating $PowerShellHelpPath"
        New-Item -Path $PowerShellHelpPath -ItemType Directory -Force | Out-Null
    }
    #=================================================
    # OSD.Workspace Module
    $ModuleName = 'OSD.Workspace'
    
    if ((-not (Test-Path "$PowerShellHelpPath\$ModuleName")) -or $Force) {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Building $PowerShellHelpPath\$ModuleName"
        New-MarkdownHelp -Module $ModuleName -OutputFolder "$PowerShellHelpPath\$ModuleName" -Force | Out-Null
    }
    else {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Use the -Force parameter to update $ModuleName"
    }
    #=================================================
    # Dism Module
    $ModuleName = 'Dism'
    
    if ((-not (Test-Path "$PowerShellHelpPath\$ModuleName")) -or $Force) {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Update-Help $ModuleName"
        Update-Help -Module $ModuleName -Force | Out-Null

        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Building $PowerShellHelpPath\$ModuleName"
        New-MarkdownHelp -Module $ModuleName -OutputFolder "$PowerShellHelpPath\$ModuleName" -Force | Out-Null
    }
    else {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Use the -Force parameter to update $ModuleName"
    }
    #=================================================
}