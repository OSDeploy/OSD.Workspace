function Initialize-OSDWorkspace {
    [CmdletBinding()]
    param ()
    #=================================================
    $Error.Clear()
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
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
        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] OSDWorkspace is running on a Windows Client OS"
    }
    else {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] OSDWorkspace is not running on a Windows Client OS"
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] This configuration is not supported and initialization will not continue"
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] OSDWorkspace is only supported on Windows 11 24H2 and newer"
        break
    }
    #=================================================
    # Test Win32_OperatingSystem BuildNumber
    $osInfo = Get-CimInstance Win32_OperatingSystem
    if ($osInfo.BuildNumber -ge 26100) {
        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] OSDWorkspace is running on a Windows Client OS with BuildNumber $($osInfo.BuildNumber)"
    }
    else {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] OSDWorkspace requires a Windows Client OS with BuildNumber 26100 or higher"
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] This configuration is not supported and initialization will not continue"
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] OSDWorkspace is only supported on Windows 11 24H2 and newer"
        break
    }
    #=================================================
    # VS Code
    if (Get-Command 'code' -ErrorAction SilentlyContinue) {
        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Microsoft VS Code is installed"
    }
    else {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Microsoft VS Code is not installed"
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Initialization will not continue"
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Use WinGet to install VS Code using the following command (saved to clipboard):"
        $InstallMessage = "winget install -e --id Microsoft.VisualStudioCode --override '/SILENT /mergetasks=`"!runcode,addcontextmenufiles,addcontextmenufolders,associatewithfiles,addtopath`"'"
        $InstallMessage | Set-Clipboard
        Write-Host -ForegroundColor DarkGray $InstallMessage
        break
    }
    #=================================================
    # Git for Windows - Reload environment
    if (-not (Get-Command 'git' -ErrorAction SilentlyContinue)) {
        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Updating environment variables"
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
        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Git for Windows is installed"
    }
    else {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Git for Windows is not installed"
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Initialization will not continue"
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Use WinGet to install Git for Windows:"
        Write-Host 'winget install -e --id Git.Git'
        break
    }
    #=================================================
    # Make sure we can get the path from the Global Variable
    $OSDWorkspacePath = $OSDWorkspace.path
    if ($OSDWorkspacePath) {
        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] OSDWorkspace will be located at $OSDWorkspacePath"
    }
    else {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] OSDWorkspace encountered an unknown error"
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Initialization will not continue"
        break
    }
    #=================================================
    # Test if OSDWorkspace exists without Git
    if ((Test-Path -Path $OSDWorkspacePath) -and (-not (Test-Path -Path "$OSDWorkspacePath\.git"))) {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] OSDWorkspace exists but is not git initialized"
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] This configuration is not supported and initialization will not continue"
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Remove $OSDWorkspacePath to continue"
        break
    }
    #=================================================
    # Create OSDWorkspace if it does not exist
    if (Test-Path -Path $OSDWorkspacePath) {
        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] OSDWorkspace exists at $OSDWorkspacePath"
    }
    else {
        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] OSDWorkspace does not exist at $OSDWorkspacePath"
        if (-not $IsAdmin ) {
            Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] OSDWorkspace first run requires Administrator rights"
            Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Initialization will not continue"
            Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Restart in PowerShell with Administrator rights"
            Break
        }
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Creating $OSDWorkspacePath"
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] git init $OSDWorkspacePath"
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
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Creating $OSDWorkspacePath\.github"
        New-Item -Path "$OSDWorkspacePath\.github" -ItemType Directory -Force | Out-Null
    }
    if (-not (Test-Path "$OSDWorkspacePath\.vscode")) {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Creating $OSDWorkspacePath\.github"
        New-Item -Path "$OSDWorkspacePath\.vscode" -ItemType Directory -Force | Out-Null
    }

    $Content = Get-Content -Path "$($MyInvocation.MyCommand.Module.ModuleBase)\local\.gitattributes" -Raw
    $Path = "$OSDWorkspacePath\.gitattributes"
    if (-not (Test-Path -Path $Path)) {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Adding $Path"
        Set-Content -Path $Path -Value $Content -Encoding UTF8 -Force
        
        # Set the value in the registry
        $RegName = '.gitattributes'
        if (-not (Get-ItemProperty $RegKey -Name $RegName -ErrorAction SilentlyContinue)) {
            try { New-ItemProperty -Path $RegKey -Name $RegName -Value $RegValue -Force | Out-Null }
            catch {}
        }
    }

    $Content = Get-Content -Path "$($MyInvocation.MyCommand.Module.ModuleBase)\local\.gitignore" -Raw
    $Path = "$OSDWorkspacePath\.gitignore"
    if (-not (Test-Path -Path $Path)) {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Adding $Path"
        Set-Content -Path $Path -Value $Content -Encoding UTF8 -Force
        
        # Set the value in the registry
        $RegName = '.gitignore'
        if (-not (Get-ItemProperty $RegKey -Name $RegName -ErrorAction SilentlyContinue)) {
            try { New-ItemProperty -Path $RegKey -Name $RegName -Value $RegValue -Force | Out-Null }
            catch {}
        }
    }

    $Content = Get-Content -Path "$($MyInvocation.MyCommand.Module.ModuleBase)\local\copilot-instructions.md" -Raw
    $Path = "$OSDWorkspacePath\.github\copilot-instructions.md"
    if (-not (Test-Path -Path $Path)) {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Adding $Path"
        Set-Content -Path $Path -Value $Content -Encoding UTF8 -Force
        
        # Set the value in the registry
        $RegName = 'copilot-instructions.md'
        if (-not (Get-ItemProperty $RegKey -Name $RegName -ErrorAction SilentlyContinue)) {
            try { New-ItemProperty -Path $RegKey -Name $RegName -Value $RegValue -Force | Out-Null }
            catch {}
        }
    }

    $Content = Get-Content -Path "$($MyInvocation.MyCommand.Module.ModuleBase)\local\launch.json" -Raw
    $Path = "$OSDWorkspacePath\.vscode\launch.json"
    if (-not (Test-Path -Path $Path)) {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Adding $Path"
        Set-Content -Path $Path -Value $Content -Encoding UTF8 -Force
        
        # Set the value in the registry
        $RegName = 'launch.json'
        if (-not (Get-ItemProperty $RegKey -Name $RegName -ErrorAction SilentlyContinue)) {
            try { New-ItemProperty -Path $RegKey -Name $RegName -Value $RegValue -Force | Out-Null }
            catch {}
        }
    }

    $Content = Get-Content -Path "$($MyInvocation.MyCommand.Module.ModuleBase)\local\tasks.json" -Raw
    $Path = "$OSDWorkspacePath\.vscode\tasks.json"
    if (-not (Test-Path -Path $Path)) {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Adding $Path"
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
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Adding $Path"
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
    $DefaultLibraryPath = $OSDWorkspace.paths.default_library

    if (-not (Test-Path "$DefaultLibraryPath\winpe-driver\amd64")) {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Creating $DefaultLibraryPath\winpe-driver"
        New-Item -Path "$DefaultLibraryPath\winpe-driver\amd64" -ItemType Directory -Force | Out-Null
    }
    if (-not (Test-Path "$DefaultLibraryPath\winpe-driver\arm64")) {
        New-Item -Path "$DefaultLibraryPath\winpe-driver\arm64" -ItemType Directory -Force | Out-Null
    }
    if (-not (Test-Path "$DefaultLibraryPath\winpe-script")) {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Creating $DefaultLibraryPath\winpe-script"
        New-Item -Path "$DefaultLibraryPath\winpe-script" -ItemType Directory -Force | Out-Null
    }
    if (-not (Test-Path "$DefaultLibraryPath\winpe-mediascript")) {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Creating $DefaultLibraryPath\winpe-mediascript"
        New-Item -Path "$DefaultLibraryPath\winpe-mediascript" -ItemType Directory -Force | Out-Null
    }
    #=================================================
}