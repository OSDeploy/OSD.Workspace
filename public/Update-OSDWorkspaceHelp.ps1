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
    $ModuleName = $($MyInvocation.MyCommand.Module.Name)
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] ModuleName: $ModuleName"
    $ModuleBase = $($MyInvocation.MyCommand.Module.ModuleBase)
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] ModuleBase: $ModuleBase"
    $ModuleVersion = $($MyInvocation.MyCommand.Module.Version)
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] ModuleVersion: $ModuleVersion"

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

    # Set Registry version information
    $RegKey = 'HKCU:\Software\OSDWorkspace'
    $RegName = $($MyInvocation.MyCommand.Name)
    $RegValue = $ModuleVersion
    try { New-ItemProperty -Path $RegKey -Name $RegName -Value $RegValue -Force | Out-Null }
    catch {}
    #=================================================
    # OSD.Workspace Module
    $ModuleName = 'OSD.Workspace'
    
    if ((-not (Test-Path "$PowerShellHelpPath\$ModuleName")) -or $Force) {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Building $PowerShellHelpPath\$ModuleName"
        New-MarkdownHelp -Module $ModuleName -OutputFolder "$PowerShellHelpPath\$ModuleName" -Force | Out-Null

        # Set Registry version information
        $RegKey = 'HKCU:\Software\OSDWorkspace'
        $RegName = 'powershell-help-osdworkspace'
        $RegValue = $ModuleVersion

        if (-not (Get-ItemProperty $RegKey -Name $RegName -ErrorAction SilentlyContinue)) {
            try { New-ItemProperty -Path $RegKey -Name $RegName -Value $RegValue -Force | Out-Null }
            catch {}
        }
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

        # Set Registry version information
        $RegKey = 'HKCU:\Software\OSDWorkspace'
        $RegName = 'powershell-help-dism'
        $RegValue = $ModuleVersion

        if (-not (Get-ItemProperty $RegKey -Name $RegName -ErrorAction SilentlyContinue)) {
            try { New-ItemProperty -Path $RegKey -Name $RegName -Value $RegValue -Force | Out-Null }
            catch {}
        }
    }
    else {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Use the -Force parameter to update $ModuleName"
    }
    #=================================================
}