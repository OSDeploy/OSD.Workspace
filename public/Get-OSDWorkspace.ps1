function Get-OSDWorkspace {
    <#
    .SYNOPSIS
        Displays information about the OSD.Workspace PowerShell Module and initializes the environment.

    .DESCRIPTION
        The Get-OSDWorkspace function displays comprehensive information about the OSD.Workspace PowerShell Module, 
        including module version, team information, upcoming events, and links to resources and documentation.
        
        This function performs the following operations:
        1. Initializes the OSDWorkspace environment
        2. Displays team information and contact links
        3. Shows upcoming community events
        4. Lists important resources and documentation links
        5. Displays version information for various components
        
        This function is typically run when first starting to work with OSD.Workspace to verify
        the module is properly installed and to access important resources.

    .EXAMPLE
        Get-OSDWorkspace
        
        Displays information about the OSD.Workspace PowerShell Module and initializes the environment.

    .EXAMPLE
        Get-OSDWorkspace -Verbose
        
        Displays information about the OSD.Workspace PowerShell Module with additional verbose output 
        showing initialization steps and path information.

    .OUTPUTS
        System.Management.Automation.PSCustomObject
        Returns the OSDWorkspace configuration object that contains paths, settings, and other information.

    .NOTES
        Author: David Segura
        Version: 1.0
        Date: April 29, 2025
        
        This function calls Initialize-OSDWorkspace internally to set up the environment.
    #>

    [CmdletBinding()]
    param ()
    #=================================================
    $Error.Clear()
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Start"
    $ModuleName = $($MyInvocation.MyCommand.Module.Name)
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] ModuleName: $ModuleName"
    $ModuleBase = $($MyInvocation.MyCommand.Module.ModuleBase)
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] ModuleBase: $ModuleBase"
    $ModuleVersion = $($MyInvocation.MyCommand.Module.Version)
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] ModuleVersion: $ModuleVersion"
    #=================================================
    Write-Host -ForegroundColor DarkCyan 'OSDWorkspace Team'
    Write-Host -ForegroundColor DarkGray "David Segura $($OSDWorkspace.links.david)"
    Write-Host -ForegroundColor DarkGray "Michael Escamilla $($OSDWorkspace.links.michael)"
    Write-Host
    Write-Host -ForegroundColor DarkCyan 'NWSCUG: OSD 2025 Preview'
    Write-Host -ForegroundColor DarkGray "March 28 2025 $($OSDWorkspace.links.nwscug)"
    Write-Host
    Write-Host -ForegroundColor DarkCyan 'MMSMOA: OSDWorkspace and OSDCloud'
    Write-Host -ForegroundColor DarkGray "May 5-8 2025 $($OSDWorkspace.links.mmsmoa)"
    Write-Host
    Write-Host -ForegroundColor DarkCyan 'WPNinjasUK: OSDWorkspace and OSDCloud'
    Write-Host -ForegroundColor DarkGray "June 16-17 2025 $($OSDWorkspace.links.wpninjasuk)"
    Write-Host
    Write-Host -ForegroundColor DarkCyan 'WPNinjas: OSDWorkspace and OSDCloud'
    Write-Host -ForegroundColor DarkGray "September 22-25, 2025 | $($OSDWorkspace.links.wpninjasch)"
    Write-Host
    Write-Host -ForegroundColor DarkCyan 'OSDWorkspace on GitHub'
    Write-Host -ForegroundColor DarkGray $($OSDWorkspace.links.github)
    Write-Host
    Write-Host -ForegroundColor DarkCyan 'OSDWorkspace on PowerShell Gallery'
    Write-Host -ForegroundColor DarkGray $($OSDWorkspace.links.powershellgallery)
    Write-Host
    Write-Host -ForegroundColor DarkCyan 'OSDWorkspace on Discord'
    Write-Host -ForegroundColor DarkGray $($OSDWorkspace.links.discord)
    Write-Host
    Write-Host -ForegroundColor DarkCyan 'OSDWorkspace Components'
    Write-Host -ForegroundColor DarkGray "dism      $((Get-Command dism -ErrorAction Ignore).version.ToString())"
    if (Get-Command git.exe -ErrorAction Ignore) {
    Write-Host -ForegroundColor DarkGray "git       $((Get-Command git.exe -ErrorAction Ignore).version.ToString())"
    }
    Write-Host -ForegroundColor DarkGray "pwsh      $((Get-Command pwsh -ErrorAction Ignore).version.ToString())"
    Write-Host -ForegroundColor DarkGray "Module    $ModuleVersion"
    $RegKey = 'HKCU:\Software\OSDWorkspace'
    $RegName = 'Content'
    $RegValue = (Get-ItemProperty $RegKey -Name $RegName -ErrorAction Ignore).$RegName

    Write-Host -ForegroundColor DarkGray "Content   $RegValue"
    if ($ModuleVersion -ne $RegValue) {
        Write-Host -ForegroundColor DarkCyan 'Install-OSDWorkspace should be run'
    }
    #=================================================
    # Read the value from the registry
    # $GetValue = (Get-ItemProperty $RegKey -Name $RegName).$RegName
    #=================================================
    $null = Get-OSDWSWinRESource -WarningAction SilentlyContinue
    $null = Get-OSDWSWinOSSource -WarningAction SilentlyContinue
    $null = Get-OSDWSWinPEBuild -WarningAction SilentlyContinue
    #=================================================
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}