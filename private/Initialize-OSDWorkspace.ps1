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
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Start"
    $ModuleName = $($MyInvocation.MyCommand.Module.Name)
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] ModuleName: $ModuleName"
    $ModuleBase = $($MyInvocation.MyCommand.Module.ModuleBase)
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] ModuleBase: $ModuleBase"
    $ModuleVersion = $($MyInvocation.MyCommand.Module.Version)
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] ModuleVersion: $ModuleVersion"
    #=================================================
    $IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    #=================================================
    # Test Win32_OperatingSystem ProductType
    $osInfo = Get-CimInstance Win32_OperatingSystem
    if ($osInfo.ProductType -eq 1) {
        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] OSDWorkspace is running on a Windows Client OS"
    }
    else {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] OSDWorkspace is not running on a Windows Client OS"
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] This configuration is not supported and initialization will not continue"
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] OSDWorkspace is only supported on Windows 11 24H2 and newer"
        break
    }
    #=================================================
    # Test Win32_OperatingSystem BuildNumber
    $osInfo = Get-CimInstance Win32_OperatingSystem
    if ($osInfo.BuildNumber -ge 26100) {
        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] OSDWorkspace is running on a Windows Client OS with BuildNumber $($osInfo.BuildNumber)"
    }
    else {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] OSDWorkspace requires a Windows Client OS with BuildNumber 26100 or higher"
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] This configuration is not supported and initialization will not continue"
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] OSDWorkspace is only supported on Windows 11 24H2 and newer"
        break
    }
    #=================================================
    # VS Code
    if (Get-Command 'code' -ErrorAction SilentlyContinue) {
        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Microsoft VS Code is installed"
    }
    else {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Microsoft VS Code is not installed"
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Initialization will not continue"
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Use WinGet to install VS Code using the following command (saved to clipboard):"
        $InstallMessage = "winget install -e --id Microsoft.VisualStudioCode --override '/SILENT /mergetasks=`"!runcode,addcontextmenufiles,addcontextmenufolders,associatewithfiles,addtopath`"'"
        $InstallMessage | Set-Clipboard
        Write-Host -ForegroundColor DarkGray $InstallMessage
        break
    }
    #=================================================
    # Git for Windows - Reload environment
    if (-not (Get-Command 'git' -ErrorAction SilentlyContinue)) {
        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Updating environment variables"
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
    if (Get-Command 'git' -ErrorAction SilentlyContinue) {
        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Git for Windows is installed"
    }
    else {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Git for Windows is not installed"
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Initialization will not continue"
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Use WinGet to install Git for Windows:"
        Write-Host 'winget install -e --id Git.Git'
        break
    }
    #=================================================
    # Make sure we can get the path from the Global Variable
    $OSDWorkspacePath = $OSDWorkspace.path
    if ($OSDWorkspacePath) {
        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] OSDWorkspace will be located at $OSDWorkspacePath"
    }
    else {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] OSDWorkspace encountered an unknown error"
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Initialization will not continue"
        break
    }
    #=================================================
    # Test if OSDWorkspace exists without Git
    if ((Test-Path -Path $OSDWorkspacePath) -and (-not (Test-Path -Path "$OSDWorkspacePath\.git"))) {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] OSDWorkspace exists but is not git initialized"
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] This configuration is not supported and initialization will not continue"
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Remove $OSDWorkspacePath to continue"
        break
    }
    #=================================================
    # Create OSDWorkspace if it does not exist
    if (Test-Path -Path $OSDWorkspacePath) {
        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] OSDWorkspace exists at $OSDWorkspacePath"
    }
    else {
        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] OSDWorkspace does not exist at $OSDWorkspacePath"
        if (-not $IsAdmin ) {
            Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] OSDWorkspace first run requires Administrator rights"
            Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Initialization will not continue"
            Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Restart in PowerShell with Administrator rights"
            Break
        }
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Creating $OSDWorkspacePath"
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] git init $OSDWorkspacePath"
        $null = git init "$OSDWorkspacePath"
    }
    #=================================================
    # Add Registry Key for OSDWorkspace
    $RegKey = 'HKCU:\Software\OSDWorkspace'
    $RegName = 'Initialize-OSDWorkspace'
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
    # Add Git Configuration
    if (-not (Test-Path "$OSDWorkspacePath\.github")) {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Creating $OSDWorkspacePath\.github"
        New-Item -Path "$OSDWorkspacePath\.github" -ItemType Directory -Force | Out-Null
    }
    if (-not (Test-Path "$OSDWorkspacePath\.vscode")) {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Creating $OSDWorkspacePath\.github"
        New-Item -Path "$OSDWorkspacePath\.vscode" -ItemType Directory -Force | Out-Null
    }

    <#
    $Content = Get-Content -Path "$($MyInvocation.MyCommand.Module.ModuleBase)\local\.gitattributes" -Raw
    $Path = "$OSDWorkspacePath\.gitattributes"
    if (-not (Test-Path -Path $Path)) {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Adding $Path"
        Set-Content -Path $Path -Value $Content -Encoding UTF8 -Force
        
        # Set the value in the registry
        $RegName = '.gitattributes'
        if (-not (Get-ItemProperty $RegKey -Name $RegName -ErrorAction SilentlyContinue)) {
            try { New-ItemProperty -Path $RegKey -Name $RegName -Value $RegValue -Force | Out-Null }
            catch {}
        }
    }
    #>

    $Content = Get-Content -Path "$($MyInvocation.MyCommand.Module.ModuleBase)\local\.gitignore" -Raw
    $Path = "$OSDWorkspacePath\.gitignore"
    if (-not (Test-Path -Path $Path)) {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Adding $Path"
        Set-Content -Path $Path -Value $Content -Encoding UTF8 -Force
        
        # Set the value in the registry
        $RegName = '.gitignore'
        if (-not (Get-ItemProperty $RegKey -Name $RegName -ErrorAction SilentlyContinue)) {
            try { New-ItemProperty -Path $RegKey -Name $RegName -Value $RegValue -Force | Out-Null }
            catch {}
        }
    }

    <#
    $Content = Get-Content -Path "$($MyInvocation.MyCommand.Module.ModuleBase)\local\copilot-instructions.md" -Raw
    $Path = "$OSDWorkspacePath\.github\copilot-instructions.md"
    if (-not (Test-Path -Path $Path)) {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Adding $Path"
        Set-Content -Path $Path -Value $Content -Encoding UTF8 -Force
        
        # Set the value in the registry
        $RegName = 'copilot-instructions.md'
        if (-not (Get-ItemProperty $RegKey -Name $RegName -ErrorAction SilentlyContinue)) {
            try { New-ItemProperty -Path $RegKey -Name $RegName -Value $RegValue -Force | Out-Null }
            catch {}
        }
    }
    #>

    $Content = Get-Content -Path "$($MyInvocation.MyCommand.Module.ModuleBase)\local\tasks.json" -Raw
    $Path = "$OSDWorkspacePath\.vscode\tasks.json"
    if (-not (Test-Path -Path $Path)) {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Adding $Path"
        Set-Content -Path $Path -Value $Content -Encoding UTF8 -Force
        
        # Set the value in the registry
        $RegName = 'tasks.json'
        if (-not (Get-ItemProperty $RegKey -Name $RegName -ErrorAction SilentlyContinue)) {
            try { New-ItemProperty -Path $RegKey -Name $RegName -Value $RegValue -Force | Out-Null }
            catch {}
        }
    }

    $Content = Get-Content -Path "$($MyInvocation.MyCommand.Module.ModuleBase)\local\OSD.code-workspace" -Raw
    $Path = "$OSDWorkspacePath\OSD.code-workspace"
    if (-not (Test-Path -Path $Path)) {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Adding $Path"
        Set-Content -Path $Path -Value $Content -Encoding UTF8 -Force
        
        # Set the value in the registry
        $RegName = 'OSD.code-workspace'
        if (-not (Get-ItemProperty $RegKey -Name $RegName -ErrorAction SilentlyContinue)) {
            try { New-ItemProperty -Path $RegKey -Name $RegName -Value $RegValue -Force | Out-Null }
            catch {}
        }
    }
    #=================================================
    # Update Default Library
    $LibraryDefaultPath = $OSDWorkspace.paths.library_default

    if (-not (Test-Path "$LibraryDefaultPath\winpe-driver\amd64")) {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Creating $LibraryDefaultPath\winpe-driver"
        New-Item -Path "$LibraryDefaultPath\winpe-driver\amd64" -ItemType Directory -Force | Out-Null
    }
    if (-not (Test-Path "$LibraryDefaultPath\winpe-driver\arm64")) {
        New-Item -Path "$LibraryDefaultPath\winpe-driver\arm64" -ItemType Directory -Force | Out-Null
    }
    if (-not (Test-Path "$LibraryDefaultPath\winpe-script")) {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Creating $LibraryDefaultPath\winpe-script"
        New-Item -Path "$LibraryDefaultPath\winpe-script" -ItemType Directory -Force | Out-Null
    }
    if (-not (Test-Path "$LibraryDefaultPath\winpe-mediascript")) {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Creating $LibraryDefaultPath\winpe-mediascript"
        New-Item -Path "$LibraryDefaultPath\winpe-mediascript" -ItemType Directory -Force | Out-Null
    }
    #=================================================
    # Make sure the OSDWorkspace machine has Nuget installed
    if ($(Get-PackageProvider).Name -notcontains "NuGet") {
        Install-PackageProvider -Name NuGet -Force
    }
    #=================================================
    # Is PackageManagement installed?
    $InstalledModule = Get-Module -Name PackageManagement -ListAvailable | Where-Object { $_.Version -ge '1.4.8.1' }
    if (-not ($InstalledModule)) {
        Install-Module -Name PackageManagement -Force -Scope AllUsers -AllowClobber -SkipPublisherCheck
    }
    #=================================================
    # Is PowerShellGet installed?
    $InstalledModule = Get-Module -Name PowerShellGet -ListAvailable | Where-Object { $_.Version -ge '2.2.5'}
    if (-not ($InstalledModule)) {
        Install-Module -Name PowerShellGet -Force -Scope AllUsers -AllowClobber -SkipPublisherCheck
    }
    #=================================================
    # CachePowerShellModules
    $CachePowerShellModules = $OSDWorkspace.paths.powershell_modules
    if (-not (Test-Path -Path $CachePowerShellModules)) {
        New-Item -Path $CachePowerShellModules -ItemType Directory -Force | Out-Null
        Save-Module -Name PackageManagement -Path $CachePowerShellModules -Repository PSGallery -Force -ErrorAction SilentlyContinue
        Save-Module -Name PowerShellGet -Path $CachePowerShellModules -Repository PSGallery -Force -ErrorAction SilentlyContinue
    }
    #=================================================
    # CachePSRepository
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
    #=================================================
}