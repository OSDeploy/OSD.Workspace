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
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Git for Windows is not installed.  Use WinGet to install Git for Windows:"
        Write-Host 'winget install -e --id Git.Git'
        Break
    }
    #endregion
    #=================================================
    #region Require Git for Windows
    if (-not (Get-Module platyPS -ListAvailable -ErrorAction SilentlyContinue)) {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] PowerShell Module platyPS is not installed.  Use the following PowerShell command to resolve this issue:"
        Write-Host 'Install-Module -Name platyPS -Scope CurrentUser'
        Write-Host 'Import-Module platyPS'
        Start-Sleep -Seconds 10
    }
    #endregion
    #=================================================
    #TODO Update the GitIgnore
    #region GitIgnore
    $gitignore = @'
# Updated 2025.03.10 Segura

# VSCodeIgnore/*
.vs/*
.vscode/*

# OSDWorkspace Defaults
# This level is just enough to capture the index files
build/*/*
cache/*/*
src/*/*

# OSDWorkspace Files
# These should be excludes as they can be too large
# but adjust accordingly
*.cab
*.esd
*.iso
*.swm
*.wim
*.zip

# WindowsUpdate
*kb*.cab
*.msu

# WinPE Registry Hives
SOFTWARE
SYSTEM

# Software
**/PortableGit*/*
'@
    #endregion
    #=================================================
    #region GitAttributes
    $gitattributes = @'
# Common settings that generally should always be used with your language specific settings

# Auto detect text files and perform LF normalization
*          text=auto

#
# The above will handle all files NOT found below
#

# Documents
*.bibtex   text diff=bibtex
*.doc      diff=astextplain
*.DOC      diff=astextplain
*.docx     diff=astextplain
*.DOCX     diff=astextplain
*.dot      diff=astextplain
*.DOT      diff=astextplain
*.pdf      diff=astextplain
*.PDF      diff=astextplain
*.rtf      diff=astextplain
*.RTF      diff=astextplain
*.md       text diff=markdown
*.mdx      text diff=markdown
*.tex      text diff=tex
*.adoc     text
*.textile  text
*.mustache text
*.csv      text eol=crlf
*.tab      text
*.tsv      text
*.txt      text
*.sql      text
*.epub     diff=astextplain

# Graphics
*.png      binary
*.jpg      binary
*.jpeg     binary
*.gif      binary
*.tif      binary
*.tiff     binary
*.ico      binary
# SVG treated as text by default.
*.svg      text
# If you want to treat it as binary,
# use the following line instead.
# *.svg    binary
*.eps      binary

# Scripts
*.bash     text eol=lf
*.fish     text eol=lf
*.ksh      text eol=lf
*.sh       text eol=lf
*.zsh      text eol=lf
# These are explicitly windows files and should use crlf
*.bat      text eol=crlf
*.cmd      text eol=crlf
*.ps1      text eol=crlf

# Serialisation
*.json     text
*.toml     text
*.xml      text
*.yaml     text
*.yml      text

# Archives
*.7z       binary
*.bz       binary
*.bz2      binary
*.bzip2    binary
*.gz       binary
*.lz       binary
*.lzma     binary
*.rar      binary
*.tar      binary
*.taz      binary
*.tbz      binary
*.tbz2     binary
*.tgz      binary
*.tlz      binary
*.txz      binary
*.xz       binary
*.Z        binary
*.zip      binary
*.zst      binary

# Text files where line endings should be preserved
*.patch    -text

#
# Exclude files from exporting
#

#.gitattributes export-ignore
#.gitignore     export-ignore
.gitkeep       export-ignore

# Basic .gitattributes for a PowerShell repo.

# Source files
# ============
*.ps1      text eol=crlf
*.ps1x     text eol=crlf
*.psm1     text eol=crlf
*.psd1     text eol=crlf
*.ps1xml   text eol=crlf
*.pssc     text eol=crlf
*.psrc     text eol=crlf
*.cdxml    text eol=crlf
'@
    #endregion
    #=================================================
    #region OSDWorkspacePath
    # Path will always default to C:\OSDWorkspace
    $ParentPath = $env:SystemDrive
    $ChildPath = 'OSDWorkspace'
    $OSDWorkspacePath = Join-Path -Path $ParentPath -ChildPath $ChildPath
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
    $MarkdownHelpPath = "$OSDWorkspacePath\docs\powershell-help"
    if (Get-Module platyPS -ListAvailable -ErrorAction SilentlyContinue) {
        if (-not (Test-Path $MarkdownHelpPath)) {
            Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Creating $MarkdownHelpPath"
            New-Item -Path $MarkdownHelpPath -ItemType Directory -Force | Out-Null
        }
        if (-not (Test-Path "$MarkdownHelpPath\Dism")) {
            Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Update-Help Dism"
            Update-Help -Module Dism -Force | Out-Null
            Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Building $MarkdownHelpPath\Dism"
            New-MarkdownHelp -Module 'Dism' -OutputFolder "$MarkdownHelpPath\Dism" -Force | Out-Null
        }
        if (-not (Test-Path "$MarkdownHelpPath\OSD.Workspace")) {
            if (-not (Test-Path "$MarkdownHelpPath\OSD.Workspace")) {
                Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Building $MarkdownHelpPath\OSD.Workspace"
                New-MarkdownHelp -Module 'OSD.Workspace' -OutputFolder "$MarkdownHelpPath\OSD.Workspace" -Force | Out-Null
            }
        }
    }
    #=================================================
    # Update Default Library
    if (-not (Test-Path "$OSDWorkspacePath\library\default\WinPE-Driver\amd64")) {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Creating $OSDWorkspacePath\library\default\WinPE-Driver"
        New-Item -Path "$OSDWorkspacePath\library\default\WinPE-Driver\amd64" -ItemType Directory -Force | Out-Null
    }
    if (-not (Test-Path "$OSDWorkspacePath\library\default\WinPE-Driver\arm64")) {
        New-Item -Path "$OSDWorkspacePath\library\default\WinPE-Driver\arm64" -ItemType Directory -Force | Out-Null
    }
    if (-not (Test-Path "$OSDWorkspacePath\library\default\WinPE-Script")) {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Creating $OSDWorkspacePath\library\default\WinPE-Script"
        New-Item -Path "$OSDWorkspacePath\library\default\WinPE-Script" -ItemType Directory -Force | Out-Null
    }
    if (-not (Test-Path "$OSDWorkspacePath\library\default\WinPE-MediaScript")) {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Creating $OSDWorkspacePath\library\default\WinPE-MediaScript"
        New-Item -Path "$OSDWorkspacePath\library\default\WinPE-MediaScript" -ItemType Directory -Force | Out-Null
    }

    return $OSDWorkspacePath
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}