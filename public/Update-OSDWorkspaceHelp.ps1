function Update-OSDWorkspaceHelp {
    <#
    .SYNOPSIS
        Generates and updates PowerShell help documentation for the OSD.Workspace module.

    .DESCRIPTION
        The Update-OSDWorkspaceHelp function generates and updates the PowerShell help documentation 
        files for the OSD.Workspace module. This includes creating or refreshing Markdown-based help 
        files in the OSDWorkspace documentation directory (C:\OSDWorkspace\docs\powershell-help).
        
        This function performs the following operations:
        1. Checks if the platyPS module is installed and installs it if needed
        2. Creates the destination directory for help files if it doesn't exist
        3. Generates help documentation for the OSD.Workspace module
        4. Optionally generates help documentation for the DISM module
        5. Writes the documentation files to the appropriate locations
        
        When run without the -Force parameter, this function will only update help files
        if they don't already exist. Use -Force to regenerate all help files.

    .PARAMETER Force
        Switch parameter that forces regeneration of all help files, 
        even if they already exist.

    .EXAMPLE
        Update-OSDWorkspaceHelp
        
        Checks if PowerShell help files exist for the OSD.Workspace module and creates them 
        if they don't exist.

    .EXAMPLE
        Update-OSDWorkspaceHelp -Force
        
        Regenerates all PowerShell help files for the OSD.Workspace module, 
        overwriting any existing files.

    .EXAMPLE
        Update-OSDWorkspaceHelp -Verbose
        
        Updates PowerShell help files with detailed verbose output showing each step of the process.

    .OUTPUTS
        None. This function does not generate any output objects.

    .NOTES
        Author: David Segura
        Version: 1.0
        Date: April 29, 2025
        
        Prerequisites:
            - PowerShell 5.0 or higher
            - Internet connection (to install platyPS module if needed)
            
        The platyPS module is used to generate the help documentation.
        This function may require an internet connection to install the platyPS module if it's not already installed.
    #>

    
    [CmdletBinding()]
    param (
        # Force the update of OSDWorkspace PowerShell-Help
        [System.Management.Automation.SwitchParameter]
        $Force
    )
    #=================================================
    $Error.Clear()
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Start"
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
        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] PowerShell Module platyPS is installed"
    }
    else {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] PowerShell Module platyPS is not installed"
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Use PowerShell to resolve this issue:"
        Write-Host 'Install-Module -Name platyPS -Scope CurrentUser'
        Write-Host 'Import-Module platyPS'
        return
    }
    #=================================================
    # Create PowerShell-Help
    $PowerShellHelpPath = $OSDWorkspace.paths.powershell_help

    if (-not (Test-Path $PowerShellHelpPath)) {
        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Creating $PowerShellHelpPath"
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
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Building $PowerShellHelpPath\$ModuleName"
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
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Use the -Force parameter to update $ModuleName"
    }
    #=================================================
    # Dism Module
    $ModuleName = 'Dism'
    
    if ((-not (Test-Path "$PowerShellHelpPath\$ModuleName")) -or $Force) {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Update-Help $ModuleName"
        Update-Help -Module $ModuleName -Force | Out-Null

        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Building $PowerShellHelpPath\$ModuleName"
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
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Use the -Force parameter to update $ModuleName"
    }
    #=================================================
}