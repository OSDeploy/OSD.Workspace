function Update-OSDWorkspaceISO {
    <#
    .SYNOPSIS
    Updates or creates a bootable OSD Workspace ISO using the Windows ADK and available WinPE builds.

    .DESCRIPTION
    This function prepares and updates a bootable ISO for the OSD Workspace environment. It checks for required prerequisites, verifies and manages the Windows ADK installation or cache, and allows selection of the appropriate ADK version if multiple are available. The function also enables selection of a WinPE build, sets up build variables, and initiates the ISO creation process. It is intended for use on Windows 10 or higher, requires PowerShell 5.0 or above, and must be run as Administrator.

    .PARAMETER None
    This function does not accept parameters.

    .NOTES
    Author: David Segura
    Version: 1.0
    Date: May 2025

    Prerequisites:
      - PowerShell 5.0 or higher
      - Windows 10 or higher
      - Run as Administrator

    .EXAMPLE
    Update-OSDWorkspaceISO
    Runs the function to update or create the OSD Workspace ISO using the available ADK and WinPE builds.

    .LINK
    https://learn.microsoft.com/en-us/windows-hardware/get-started/adk-install
    #>

    
    [CmdletBinding()]
    param ()
    #=================================================
    $Error.Clear()
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Start"
    Initialize-OSDWorkspace
    #=================================================
    # Requires Run as Administrator
    $IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $IsAdmin ) {
        Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] This function must be Run as Administrator"
        return
    }
    #=================================================
    # Set Variables
    $ErrorActionPreference = 'Stop'
    #=================================================
    # Block
    Block-StandardUser
    Block-WindowsVersionNe10
    Block-PowerShellVersionLt5
    Block-WindowsReleaseIdLt1703
    #=================================================
    #region Test-IsWindowsAdkInstalled
    $IsWindowsAdkInstalled = Test-IsWindowsAdkInstalled -WarningAction SilentlyContinue
    $WindowsAdkInstallVersion = Get-WindowsAdkInstallVersion -WarningAction SilentlyContinue
    $WindowsAdkInstallPath = Get-WindowsAdkInstallPath -WarningAction SilentlyContinue
    
    if ($IsWindowsAdkInstalled) {
        if ($WindowsAdkInstallVersion) {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Windows ADK install version is $WindowsAdkInstallVersion"
        }
        if ($WindowsAdkInstallPath) {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Windows ADK install path is $WindowsAdkInstallPath"
        }
    }
    else {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Windows ADK is not installed."
    }
    #endregion
    #=================================================
    #region Get and Update the ADK Cache
    $WSCachePath = $OSDWorkspace.paths.cache
    $WSAdkVersionsPath = $OSDWorkspace.paths.adk_versions
    #endregion
    #=================================================
    #region If ADK is installed then we need to update the cache
    if ($IsWindowsAdkInstalled) {
        $WindowsAdkRootPath = Join-Path $WSAdkVersionsPath $WindowsAdkInstallVersion
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Windows ADK cache content is $WindowsAdkRootPath"
        $null = robocopy.exe "$WindowsAdkInstallPath" "$WindowsAdkRootPath" *.* /e /z /ndl /nfl /np /r:0 /w:0 /xj /mt:128
    }
    else {
        Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Cannot update the ADK cache because the ADK is not installed"
        $AdkSelectCacheVersion = $true
        Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] AdkSelectCacheVersion: $AdkSelectCacheVersion"
    }
    #endregion
    #=================================================
    #region Get the WindowsAdkCacheOptions
    $WindowsAdkCacheOptions = $null
    if (Test-Path $WSAdkVersionsPath) {
        $WindowsAdkCacheOptions = Get-ChildItem -Path "$WSAdkVersionsPath\*" -Directory -ErrorAction SilentlyContinue | Sort-Object -Property Name
    }
    #endregion
    #=================================================
    #region ADK is not installed and not present in the cache
    if (($IsWindowsAdkInstalled -eq $false) -and (-not $WindowsAdkCacheOptions)) {
        Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Windows ADK is not installed"
        Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] ADK cache does not contain an offline Windows ADK"
        Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Windows ADK will need to be installed before using this function"
        Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] https://learn.microsoft.com/en-us/windows-hardware/get-started/adk-install"
        return
    }
    #endregion
    #=================================================
    #region There is no usable ADK in the cache
    if ($WindowsAdkCacheOptions.Count -eq 0) {
        # Something is wrong, there should always be at least one ADK in the cache
        Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] ADK cache does not contain an offline Windows ADK"
        Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Windows ADK will need to be installed before using this function"
        return
    }
    #endregion
    #=================================================
    #region ADK is available by this point and we either have 1 or more to select from
    if ($WindowsAdkCacheOptions.Count -eq 1) {
        # Only one version of the ADK is present in the cache, so this must be used
        $WindowsAdkRootPath = $WindowsAdkCacheOptions.FullName
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] ADK cache contains 1 offline Windows ADK option"
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Using ADK cache at $WindowsAdkCacheSelected"

        # Can't select an ADK Version if there is only one
        $AdkSelectCacheVersion = $false
    }
    elseif ($WindowsAdkCacheOptions.Count -gt 1) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] $($WindowsAdkCacheOptions.Count) Windows ADK options are available to select from the ADK cache"
        if ($AdkSelectCacheVersion) {
            Write-Host -ForegroundColor DarkCyan "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Select a Windows ADK option and press OK (Cancel to Exit)"
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] To remove a Windows ADK option, delete one of the ADK cache directories in $WSAdkVersionsPath"
            $WindowsAdkCacheSelected = $WindowsAdkCacheOptions | Select-Object FullName | Sort-Object FullName -Descending | Out-GridView -Title 'Select a Windows ADK to use and press OK (Cancel to Exit)' -OutputMode Single
            if ($WindowsAdkCacheSelected) {
                $WindowsAdkRootPath = $WindowsAdkCacheSelected.FullName
            }
            else {
                Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Unable to set the ADK cache path"
                return
            }
        }
    }
    else {
        Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Something is wrong you should not be here"
        return
    }
    #endregion
    #=================================================
    # Do we have a Boot Media?
    $SelectWinPEMedia = Select-OSDWSWinPEBuild
    if ($null -eq $SelectWinPEMedia) {
        Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] No OSDWorkspace WinPE Build was found or selected"
        return
    }
    #=================================================
    # Set the variables
    $BuildDateTime = $((Get-Date).ToString('yyMMdd-HHmm'))
    $MediaIsoLabel

    $MediaPathEX = Join-Path $SelectWinPEMedia.Path 'WinPE-MediaEX'
    if (-not (Test-Path $MediaPathEX)) {
        $MediaPathEX = $null
    }
    
    $global:BuildMedia = $null
    $global:BuildMedia = [ordered]@{
        AdkRootPath             = $WindowsAdkRootPath
        MediaIsoLabel           = $BuildDateTime
        MediaIsoName            = 'BootMedia.iso'
        MediaIsoNameEX          = 'BootMediaEX.iso'
        MediaPath               = Join-Path $SelectWinPEMedia.Path 'WinPE-Media'
        MediaPathEX             = $MediaPathEX
        MediaRootPath           = $SelectWinPEMedia.Path
    }

    Step-BuildMediaIso
    #=================================================
}
