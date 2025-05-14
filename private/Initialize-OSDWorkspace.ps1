function Initialize-OSDWorkspace {
    <#
    .SYNOPSIS
        Initializes the OSDWorkspace environment by checking for required software, creating necessary directories, and setting up Git configuration.

    .DESCRIPTION
        This function initializes the OSDWorkspace environment by checking for required software, creating necessary directories, and setting up Git configuration.
        It verifies the operating system version, checks for the presence of Microsoft VS Code and Git for Windows, and creates the OSDWorkspace directory if it does not exist.
        It also sets up Git configuration files and updates the default library structure.

    .EXAMPLE
        Initialize-OSDWorkspace

    .NOTES
        David Segura
    #>
    [CmdletBinding()]
    param ()
    #=================================================
    $Error.Clear()
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Start"
    $ModuleVersion = $($MyInvocation.MyCommand.Module.Version)
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] ModuleVersion: $ModuleVersion"
    #=================================================
    $IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    #=================================================
    # Make sure we can get the path from the Global Variable
    $OSDWorkspacePath = $OSDWorkspace.path
    if ($OSDWorkspacePath) {
        Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] OSDWorkspace will be located at $OSDWorkspacePath"
    }
    else {
        Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] OSDWorkspace encountered an unknown error"
        Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Initialization will not continue"
        break
    }
    #=================================================
    # Does OSDWorkspace exist?
    if (-not (Test-Path $(Get-OSDWorkspacePath))) {
        Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] OSDWorkspace does not exist"
        Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Run Install-OSDWorkspace to resolve this issue"
    }
    #=================================================
    # Add Registry Key for OSDWorkspace
    $RegKey = 'HKCU:\Software\OSDWorkspace'
    $RegName = 'Initialize-OSDWorkspace'
    $RegValue = $ModuleVersion

    # Test if RegKey exists
    if (-not (Test-Path $RegKey -ErrorAction SilentlyContinue)) {
        Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] OSDWorkspace is not configured properly"
        Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Run Install-OSDWorkspace to resolve this issue"
    }
    #=================================================
    # Update Default Library
    $LibraryDefaultPath = $OSDWorkspace.paths.library_default

    if (-not (Test-Path "$LibraryDefaultPath\winpe-driver\amd64")) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Creating $LibraryDefaultPath\winpe-driver"
        New-Item -Path "$LibraryDefaultPath\winpe-driver\amd64" -ItemType Directory -Force | Out-Null
    }
    if (-not (Test-Path "$LibraryDefaultPath\winpe-driver\arm64")) {
        New-Item -Path "$LibraryDefaultPath\winpe-driver\arm64" -ItemType Directory -Force | Out-Null
    }
    if (-not (Test-Path "$LibraryDefaultPath\winpe-script")) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Creating $LibraryDefaultPath\winpe-script"
        New-Item -Path "$LibraryDefaultPath\winpe-script" -ItemType Directory -Force | Out-Null
    }
    if (-not (Test-Path "$LibraryDefaultPath\winpe-mediascript")) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Creating $LibraryDefaultPath\winpe-mediascript"
        New-Item -Path "$LibraryDefaultPath\winpe-mediascript" -ItemType Directory -Force | Out-Null
    }
    #=================================================
}