function Get-OSDWorkspacePath {
    <#
    .SYNOPSIS
        Returns the OSDWorkspace Path. Default is C:\OSDWorkspace.

    .DESCRIPTION
        Returns the OSDWorkspace Path. Default is C:\OSDWorkspace.

    .NOTES
        David Segura
    #>
    <#
    .SYNOPSIS
        Returns the OSDWorkspace Path.

    .DESCRIPTION
        Returns the OSDWorkspace Path.

    .NOTES
        David Segura
    #>
    [CmdletBinding()]
    param ()
    #=================================================
    $Error.Clear()
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
    $IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    #=================================================
    #region Update Windows Environment
    if (-NOT (Get-Command 'git' -ErrorAction SilentlyContinue)) {
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
    #endregion
    #=================================================
    #region Require Git for Windows
    if (-NOT (Get-Command 'git' -ErrorAction SilentlyContinue)) {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Git for Windows is not installed"
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Use WinGet to install Git for Windows:"
        Write-Host 'winget install -e --id Git.Git'
        Break
    }
    #endregion
    #=================================================
    #region Require platyPS
    if (-not (Get-Module platyPS -ListAvailable -ErrorAction SilentlyContinue)) {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] PowerShell Module platyPS is not installed"
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Use PowerShell to resolve this issue:"
        Write-Host 'Install-Module -Name platyPS -Scope CurrentUser'
        Write-Host 'Import-Module platyPS'
        Break
    }
    #endregion
    #=================================================
    #region Get Resources
    $gitignore = Get-Content -Path "$($MyInvocation.MyCommand.Module.ModuleBase)\resources\.gitignore" -Raw
    $gitattributes = Get-Content -Path "$($MyInvocation.MyCommand.Module.ModuleBase)\resources\.gitattributes" -Raw
    #endregion
    #=================================================
    #region OSDWorkspacePath
    # Path will always default to C:\OSDWorkspace
    $OSDWorkspacePath = $OSDWorkspace.paths.root
    #endregion
    #=================================================
    #region OSDWorkspace Registry
    # OSDWorkspace should store the location in the registry
    $RegKey = 'HKCU:\Software\OSDWorkspace'
    $RegName = 'OSDWorkspacePath'
    $RegValue = $OSDWorkspacePath

    # Test if RegKey exists
    if (-not (Test-Path $RegKey -ErrorAction SilentlyContinue)) {
        try {
            New-Item 'HKCU:\Software' -Name 'OSDWorkspace' -Force | Out-Null
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] New-Item $RegKey"
        }
        catch {
            Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] New-Item $RegKey"
            break
        }
    }

    # Test if RegName exists
    if (-not (Get-ItemProperty $RegKey -Name $RegName -ErrorAction SilentlyContinue)) {
        try {
            New-ItemProperty -Path $RegKey -Name $RegName -Value $RegValue -Force | Out-Null
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] New-ItemProperty $RegKey $RegName $RegValue"
        }
        catch {
            Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] New-ItemProperty $RegKey $RegName $RegValue"
            break
        }
    }

    # By this point we have set the RegValue or we need to read it
    #TODO - Make this better
    $OSDWorkspacePath = (Get-ItemProperty $RegKey -Name $RegName).OSDWorkspacePath

    if (-not $OSDWorkspacePath) {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Unable to read $RegKey $RegName"
        break
    }
    #endregion
    #=================================================
    # Create OSDWorkspace if it does not exist
    if (-not (Test-Path -Path $OSDWorkspacePath)) {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] OSDWorkspace will be created at $OSDWorkspacePath"

        if (-not $IsAdmin ) {
            Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] OSDWorkspace first run must be run with Administrator privileges"
            Break
        }

        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] git init $OSDWorkspacePath"
        $null = git init "$OSDWorkspacePath"

        # Build OSDWorkspace
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] GitIgnore is being added at $OSDWorkspacePath\.gitignore"
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Review the contents of this file for accuracy before committing"
        $gitignore | Set-Content -Path (Join-Path -Path $OSDWorkspacePath -ChildPath '.gitignore') -Encoding utf8

        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] GitAtributes is being added at $OSDWorkspacePath\.gitignore"
        $gitattributes | Set-Content -Path (Join-Path -Path $OSDWorkspacePath -ChildPath '.gitattributes') -Encoding utf8
    }
    #=================================================
    # Update PowerShell-Help
    $PowerShellHelpPath = $OSDWorkspace.paths.powershell_help

    if (Get-Module platyPS -ListAvailable -ErrorAction SilentlyContinue) {
        if (-not (Test-Path $PowerShellHelpPath)) {
            Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Creating $PowerShellHelpPath"
            New-Item -Path $PowerShellHelpPath -ItemType Directory -Force | Out-Null
        }
        if (-not (Test-Path "$PowerShellHelpPath\Dism")) {
            Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Update-Help Dism"
            Update-Help -Module Dism -Force | Out-Null
            Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Building $PowerShellHelpPath\Dism"
            New-MarkdownHelp -Module 'Dism' -OutputFolder "$PowerShellHelpPath\Dism" -Force | Out-Null
        }
        if (-not (Test-Path "$PowerShellHelpPath\OSD.Workspace")) {
            if (-not (Test-Path "$PowerShellHelpPath\OSD.Workspace")) {
                Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Building $PowerShellHelpPath\OSD.Workspace"
                New-MarkdownHelp -Module 'OSD.Workspace' -OutputFolder "$PowerShellHelpPath\OSD.Workspace" -Force | Out-Null
            }
        }
    }
    #=================================================
    # Update Default Library
    $DefaultLibraryPath = $OSDWorkspace.paths.default_library

    if (-not (Test-Path "$DefaultLibraryPath\WinPE-Driver\amd64")) {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Creating $DefaultLibraryPath\WinPE-Driver"
        New-Item -Path "$DefaultLibraryPath\WinPE-Driver\amd64" -ItemType Directory -Force | Out-Null
    }
    if (-not (Test-Path "$DefaultLibraryPath\WinPE-Driver\arm64")) {
        New-Item -Path "$DefaultLibraryPath\WinPE-Driver\arm64" -ItemType Directory -Force | Out-Null
    }
    if (-not (Test-Path "$DefaultLibraryPath\WinPE-Script")) {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Creating $DefaultLibraryPath\WinPE-Script"
        New-Item -Path "$DefaultLibraryPath\WinPE-Script" -ItemType Directory -Force | Out-Null
    }
    if (-not (Test-Path "$DefaultLibraryPath\WinPE-MediaScript")) {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Creating $DefaultLibraryPath\WinPE-MediaScript"
        New-Item -Path "$DefaultLibraryPath\WinPE-MediaScript" -ItemType Directory -Force | Out-Null
    }

    return $OSDWorkspacePath
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}