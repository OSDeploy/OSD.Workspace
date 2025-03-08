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
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
    $Error.Clear()
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
    #TODO Update the GitIgnore
    #region GitIgnore
    $gitignore = @'
# VSCode
Ignore/*
.vs/*
.vscode/*

# BootMediaIso
*.iso

# WindowsImage
*.wim
*.swm

# WindowsUpdate
*kb*.cab
*.msu

# PowerShell
*.ps1

# OSDWorkspace
BootImage/*/
BootMedia/*/*
Cache/*/*
Library/WinPE-MediaScript/*/*
Library/WinPE-Driver/*/*/*/*
Library/WinPE-Script/*/*
Library-GitHub/*/*

# OSDFramework Content
**/PortableGit*/*

# BootImage os-files
**/os-files/*

# BootImage Registry Hives
SOFTWARE
SYSTEM
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
    if (-not (Test-Path -Path $OSDWorkspacePath)) {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] OSDWorkspace will be created at $OSDWorkspacePath"
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] If this is your first time using OSDWorkspace, it is recommended that you review the documentation"
        Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] https://github.com/OSDeploy/OSDWorkspace-Template"
        
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

        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Creating $OSDWorkspacePath\.cache"
        New-Item -Path "$OSDWorkspacePath" -Name '.cache' -ItemType Directory -Force | Out-Null

        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Creating $OSDWorkspacePath\.import\WinOS"
        New-Item -Path "$OSDWorkspacePath\.import" -Name 'WinOS' -ItemType Directory -Force | Out-Null

        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Creating $OSDWorkspacePath\.import\WinRE"
        New-Item -Path "$OSDWorkspacePath\.import" -Name 'WinRE' -ItemType Directory -Force | Out-Null

        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Creating $OSDWorkspacePath\build"
        New-Item -Path "$OSDWorkspacePath\build" -ItemType Directory -Force | Out-Null

        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Creating $OSDWorkspacePath\docs\psmodules"
        New-Item -Path "$OSDWorkspacePath\docs\psmodules" -ItemType Directory -Force | Out-Null

        if (Get-Command -Name 'New-MarkdownHelp') {
            Update-Help -Module Dism -Force | Out-Null
            $MarkdownHelpPath = "$OSDWorkspacePath\docs\psmodules"
            New-MarkdownHelp -Module Dism -OutputFolder $MarkdownHelpPath -Force | Out-Null
            New-MarkdownHelp -Module OSD.Workspace -OutputFolder $MarkdownHelpPath -Force | Out-Null
        }

        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Creating $OSDWorkspacePath\library"
        New-Item -Path "$OSDWorkspacePath\library" -ItemType Directory -Force | Out-Null
        Push-Location "$OSDWorkspacePath\library"
        git submodule init "$OSDWorkspacePath\library"
        Pop-Location
        New-Item -Path "$OSDWorkspacePath\library\WinPE-Driver" -ItemType Directory -Force | Out-Null
        New-Item -Path "$OSDWorkspacePath\library\WinPE-Driver\amd64" -ItemType Directory -Force | Out-Null
        New-Item -Path "$OSDWorkspacePath\library\WinPE-Driver\arm64" -ItemType Directory -Force | Out-Null
        New-Item -Path "$OSDWorkspacePath\library\WinPE-Script" -ItemType Directory -Force | Out-Null
        New-Item -Path "$OSDWorkspacePath\library\Build-WinPEProfile" -ItemType Directory -Force | Out-Null
        New-Item -Path "$OSDWorkspacePath\library\WinPE-MediaScript" -ItemType Directory -Force | Out-Null

        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Creating $OSDWorkspacePath\library-github"
        New-Item -Path "$OSDWorkspacePath\library-github" -ItemType Directory -Force | Out-Null
    }

    return $OSDWorkspacePath
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}