function Install-OSDWorkspace {
    <#
    .SYNOPSIS
        Initializes and configures the OSDWorkspace environment.

    .DESCRIPTION
        The Install-OSDWorkspace function performs a series of checks and setup steps to ensure the OSDWorkspace is correctly configured.
        This includes verifying the operating system, required software (VS Code, Git), PowerShell modules (NuGet, PackageManagement, PowerShellGet, platyPS, OSD),
        and setting up the OSDWorkspace directory structure, Git repository, and necessary configuration files.
        It also creates registry entries for OSDWorkspace and updates the default library paths.
        The function requires Administrator privileges for the initial setup if the OSDWorkspace directory does not exist.

    .NOTES
        Author: David Segura
        Requires Administrator privileges for the first run to create the OSDWorkspace directory.
        Ensures that the operating system is Windows Client OS, build 26100 or higher.
        Installs or updates necessary PowerShell modules like PackageManagement, PowerShellGet, platyPS, and OSD.
        Verifies the installation of VS Code and Git.
        Initializes the OSDWorkspace git repository if it doesn't exist.
        Creates standard OSDWorkspace files like .gitattributes, .gitignore, .github/copilot-instructions.md, and OSD.code-workspace.

    .EXAMPLE
        Install-OSDWorkspace

        Description:
        Runs the OSDWorkspace installation and configuration process. This command should be run in a PowerShell console.
        If it's the first time running and the OSDWorkspace directory (e.g., C:\OSDWorkspace) doesn't exist,
        it must be run with Administrator privileges.

    #>

    [CmdletBinding()]
    param ()
    #=================================================
    $Error.Clear()
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Start"
    #=================================================
    $ModuleBase = Get-OSDWorkspaceModulePath
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] ModuleBase: $ModuleBase"
    $ModuleVersion = Get-OSDWorkspaceModuleVersion
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] ModuleVersion: $ModuleVersion"
    #=================================================
    $IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    #=================================================
    # Make sure we are running in a Windows Client OS
    $osInfo = Get-CimInstance Win32_OperatingSystem
    if ($osInfo.ProductType -eq 1) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] OSDWorkspace is running on a Windows Client OS"
    }
    else {
        Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] OSDWorkspace is not running on a Windows Client OS"
        Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] This configuration is not supported and initialization will not continue"
        Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] OSDWorkspace is only supported on Windows 11 24H2 and newer"
        return
    }
    #=================================================
    # Make sure we are running in a Windows Client OS with BuildNumber 26100 or higher
    $osInfo = Get-CimInstance Win32_OperatingSystem
    if ($osInfo.BuildNumber -ge 26100) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] OSDWorkspace is running on a Windows Client OS with BuildNumber $($osInfo.BuildNumber)"
    }
    else {
        Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] OSDWorkspace requires a Windows Client OS with BuildNumber 26100 or higher"
        Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] This configuration is not supported and initialization will not continue"
        Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] OSDWorkspace is only supported on Windows 11 24H2 and newer"
        return
    }
    #=================================================
    # Make sure the OSDWorkspace machine has Nuget installed
    if ($(Get-PackageProvider).Name -notcontains "NuGet") {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Installing NuGet PackageProvider"
        Install-PackageProvider -Name NuGet -Force
    }
    #=================================================
    # Is PackageManagement installed?
    $InstalledModule = Get-Module -Name PackageManagement -ListAvailable | Where-Object { $_.Version -ge '1.4.8.1' }
    if (-not ($InstalledModule)) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Updating PackageManagement to 1.4.8.1"
        Install-Module -Name PackageManagement -Force -Scope AllUsers -AllowClobber -SkipPublisherCheck
    }
    #=================================================
    # Is PowerShellGet installed?
    $InstalledModule = Get-Module -Name PowerShellGet -ListAvailable | Where-Object { $_.Version -ge '2.2.5'}
    if (-not ($InstalledModule)) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Updating PowerShellGet to 2.2.5"
        Install-Module -Name PowerShellGet -Force -Scope AllUsers -AllowClobber -SkipPublisherCheck
    }
    #=================================================
    # VS Code
    if (Get-Command 'code' -ErrorAction SilentlyContinue) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Microsoft Visual Studio Code is installed"
    }
    elseif (Get-Command 'code-insiders' -ErrorAction SilentlyContinue) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Microsoft Visual Studio Code Insiders is installed"
    }
    else {
        Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Microsoft Visual Studio Code is not installed"
        Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Initialization will not continue"
        Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Use WinGet to install Microsoft Visual Studio Code using the following command (saved to clipboard):"
        $InstallMessage = "winget install -e --id Microsoft.VisualStudioCode --override '/SILENT /mergetasks=`"!runcode,addcontextmenufiles,addcontextmenufolders,associatewithfiles,addtopath`"'"
        $InstallMessage | Set-Clipboard
        Write-Host -ForegroundColor DarkGray $InstallMessage
        return
    }
    #=================================================
    # Git for Windows - Reload environment
    if (-not (Get-Command 'git.exe' -ErrorAction SilentlyContinue)) {
        Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Updating environment variables"
        $RegPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment', 'HKCU:\Environment'
        $RegPath | ForEach-Object {   
            $k = Get-Item $_
            $k.GetValueNames() | ForEach-Object {
                $name = $_
                $value = $k.GetValue($_)
                Set-Item -Path Env:\$name -Value $value
            }
        }
    }
    #=================================================
    # Git for Windows
    if (Get-Command 'git.exe' -ErrorAction SilentlyContinue) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Git for Windows is installed"
    }
    else {
        Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Git for Windows is not installed"
        Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Initialization will not continue"
        Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Use WinGet to install Git for Windows:"
        $InstallMessage = 'winget install -e --id Git.Git'
        $InstallMessage | Set-Clipboard
        Write-Host -ForegroundColor DarkGray $InstallMessage
        return
    }
    #=================================================
    # Make sure we can get the path from the Global Variable
    $OSDWorkspacePath = $OSDWorkspace.path
    if ($OSDWorkspacePath) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] OSDWorkspace will be located at $OSDWorkspacePath"
    }
    else {
        Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] OSDWorkspace encountered an unknown error"
        Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Initialization will not continue"
        return
    }
    #=================================================
    # Test if OSDWorkspace exists without Git
    if ((Test-Path -Path $OSDWorkspacePath) -and (-not (Test-Path -Path "$OSDWorkspacePath\.git"))) {
        Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] OSDWorkspace exists but is not git initialized"
        Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] This configuration is not supported and initialization will not continue"
        Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Remove $OSDWorkspacePath to continue"
        return
    }
    #=================================================
    # Create OSDWorkspace if it does not exist
    if (Test-Path -Path $OSDWorkspacePath) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] OSDWorkspace exists at $OSDWorkspacePath"
    }
    else {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] OSDWorkspace does not exist at $OSDWorkspacePath"
        if (-not $IsAdmin ) {
            Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] OSDWorkspace first run requires Administrator rights (elevated)"
            Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Initialization will not continue"
            Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Restart in PowerShell with Administrator rights (elevated)"
            return
        }
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Creating $OSDWorkspacePath"
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] git init $OSDWorkspacePath"
        $null = git init "$OSDWorkspacePath"
    }
    #=================================================
    # Make sure platyPS is installed
    $platyPS = Get-Module -Name platyPS -ListAvailable

    if (-not $platyPS) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Installing PowerShell Module platyPS"
        Install-Module -Name platyPS -AllowClobber -SkipPublisherCheck
    }
    else {
        Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] PowerShell Module platyPS is already installed"
    }
    #=================================================
    # Make sure OSD is installed
    $OSD = Get-Module -Name OSD -ListAvailable

    if (-not $OSD) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Installing PowerShell Module OSD"
        Install-Module -Name OSD -AllowClobber -SkipPublisherCheck
    }
    else {
        Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] PowerShell Module OSD is already installed"
    }
    #=================================================
    # Add Registry Key for OSDWorkspace
    $RegKey = 'HKCU:\Software\OSDWorkspace'
    $RegName = 'Install-OSDWorkspace'
    $RegValue = $ModuleVersion

    # Test if RegKey exists
    if (-not (Test-Path $RegKey -ErrorAction SilentlyContinue)) {
        try {New-Item 'HKCU:\Software' -Name 'OSDWorkspace' -Force | Out-Null}
        catch {}
    }

    # Set the value in the registry
    if (-not (Get-ItemProperty $RegKey -Name $RegName -ErrorAction SilentlyContinue)) {
        try {New-ItemProperty -Path $RegKey -Name $RegName -Value $RegValue -Force | Out-Null}
        catch {}
    }

    # Read the value from the registry
    # $GetValue = (Get-ItemProperty $RegKey -Name $RegName).$RegName
    #=================================================
    # Add .github
    if (-not (Test-Path "$OSDWorkspacePath\.github")) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Creating $OSDWorkspacePath\.github"
        New-Item -Path "$OSDWorkspacePath\.github" -ItemType Directory -Force | Out-Null
    }
    #=================================================
    # Add .vscode
    if (-not (Test-Path "$OSDWorkspacePath\.vscode")) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Creating $OSDWorkspacePath\.vscode"
        New-Item -Path "$OSDWorkspacePath\.vscode" -ItemType Directory -Force | Out-Null
    }
    #=================================================
    # Add .gitattributes
    $Content = Get-Content -Path "$($MyInvocation.MyCommand.Module.ModuleBase)\core\gitattributes.txt" -Raw
    $Path = "$OSDWorkspacePath\.gitattributes"
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Adding $Path"
    Set-Content -Path $Path -Value $Content -Encoding UTF8 -Force
    #=================================================
    # Add .gitignore
    $Content = Get-Content -Path "$($MyInvocation.MyCommand.Module.ModuleBase)\core\gitignore.txt" -Raw
    $Path = "$OSDWorkspacePath\.gitignore"
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Adding $Path"
    Set-Content -Path $Path -Value $Content -Encoding UTF8 -Force
    #=================================================
    # Add or update copilot-instructions.md
    $Content = Get-Content -Path "$($MyInvocation.MyCommand.Module.ModuleBase)\core\copilot-instructions.md" -Raw
    $Path = "$OSDWorkspacePath\.github\copilot-instructions.md"
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Adding $Path"
    Set-Content -Path $Path -Value $Content -Encoding UTF8 -Force
    #=================================================
    # Update Content in the registry
    $RegName = 'Content'
    try { New-ItemProperty -Path $RegKey -Name $RegName -Value $RegValue -Force | Out-Null }
    catch {}
    #=================================================
    # Add or update Update-OSDWorkspaceHelp.ps1
    Update-OSDWorkspaceHelp -Force
    #=================================================
    # Add tasks.json
    <#
    $Content = Get-Content -Path "$($MyInvocation.MyCommand.Module.ModuleBase)\core\tasks.json" -Raw
    $Path = "$OSDWorkspacePath\.vscode\tasks.json"
    if (-not (Test-Path -Path $Path)) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Adding $Path"
        Set-Content -Path $Path -Value $Content -Encoding UTF8 -Force
        
        # Set the value in the registry
        $RegName = 'tasks.json'
        if (-not (Get-ItemProperty $RegKey -Name $RegName -ErrorAction SilentlyContinue)) {
            try { New-ItemProperty -Path $RegKey -Name $RegName -Value $RegValue -Force | Out-Null }
            catch {}
        }
    }
    #>
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
    # Add OSD.code-workspace
    $Content = Get-Content -Path "$($MyInvocation.MyCommand.Module.ModuleBase)\core\OSD.code-workspace" -Raw
    $Path = "$OSDWorkspacePath\OSD.code-workspace"
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Adding $Path"
    Set-Content -Path $Path -Value $Content -Encoding UTF8 -Force
    Write-Host -ForegroundColor Cyan "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] In Windows Explorer, open the file C:\OSDWorkspace\OSD.code-workspace"
    #=================================================
    # CachePowerShellModules
    <#
        $CachePowerShellModules = $OSDWorkspace.paths.powershell_modules
        if (-not (Test-Path -Path $CachePowerShellModules)) {
            New-Item -Path $CachePowerShellModules -ItemType Directory -Force | Out-Null
            Save-Module -Name PackageManagement -Path $CachePowerShellModules -Repository PSGallery -Force -ErrorAction SilentlyContinue
            Save-Module -Name PowerShellGet -Path $CachePowerShellModules -Repository PSGallery -Force -ErrorAction SilentlyContinue
        }
    #>
    #=================================================
    # CachePSRepository
    <#
        $CachePSRepository = $OSDWorkspace.paths.psrepository
        if (-not (Test-Path -Path $CachePSRepository)) {
            New-Item -Path $CachePSRepository -ItemType Directory -Force | Out-Null

            if (-not (Get-PSRepository -Name OSDWorkspace -ErrorAction Ignore)) {
                Register-PSRepository -Name OSDWorkspace -SourceLocation $CachePSRepository -PublishLocation $CachePSRepository -InstallationPolicy Trusted
                Set-PSRepository -Name OSDWorkspace -InstallationPolicy Trusted
            }
            $ModuleBase = Get-Module -Name PackageManagement -ListAvailable | Where-Object { $_.Version -ge '1.4.8.1'} | Select-Object -First 1 -ExpandProperty ModuleBase
            Publish-Module -Path $ModuleBase -Repository OSDWorkspace -NuGetApiKey x -Force -Verbose

            $ModuleBase = Get-Module -Name PowerShellGet -ListAvailable | Where-Object { $_.Version -ge '2.2.5'} | Select-Object -First 1 -ExpandProperty ModuleBase
            Publish-Module -Path $ModuleBase -Repository OSDWorkspace -NuGetApiKey x -Force -Verbose

            Unregister-PSRepository -Name OSDWorkspace -ErrorAction SilentlyContinue
        }
    #>
    #=================================================
}