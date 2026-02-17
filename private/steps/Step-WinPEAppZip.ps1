function Step-WinPEAppZip {
    [CmdletBinding()]
    param (
        [System.String]
        $AppName = '7zip',
        [System.String]
        $Architecture = $global:BuildMedia.Architecture,
        [System.String]
        $MountPath = $global:BuildMedia.MountPath,
        [System.String]
        $WinPEAppsPath = $($OSDWorkspace.paths.winpe_apps)
    )
    #=================================================
    $Error.Clear()
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Start"
    #=================================================
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Architecture: $Architecture"
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] MountPath: $MountPath"
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] WinPEAppsPath: $WinPEAppsPath"
    #=================================================
    # Thanks Gary Blok
    $zipVersion = $global:OSDWorkspace.winpeapps.sevenzip.version
    $CacheZipRoot = Join-Path $WinPEAppsPath "7zip"
    $CacheZip = Join-Path $CacheZipRoot $zipVersion

    # Cleanup any old versions of the app in the cache
    if (Test-Path -Path $CacheZipRoot) {
        Get-ChildItem -Path $CacheZipRoot -File | Remove-Item -Force
        Get-ChildItem -Path $CacheZipRoot -Directory | Where-Object { $_.Name -ne $zipVersion } | Remove-Item -Recurse -Force
    }

    # Ensure the cache directory for this version exists, if not create it
    if (Test-Path -Path $CacheZip) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Using cache content $CacheZip"
    }
    else {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Adding cache content $CacheZip"
        New-Item -Path $CacheZip -ItemType Directory -Force | Out-Null
    }

    if (-not (Test-Path -Path "$CacheZip\7zr.exe")) {
        $DownloadStandalone = $global:OSDWorkspace.winpeapps.sevenzip.standalone
        Save-WebFile -SourceUrl $DownloadStandalone -DestinationDirectory $CacheZip
    }

    if (-not (Test-Path -Path "$CacheZip\7za")) {
        $DownloadExtra = $global:OSDWorkspace.winpeapps.sevenzip.extra
        $DownloadExtraResult = Save-WebFile -SourceUrl $DownloadExtra -DestinationDirectory $CacheZip
        $null = & "$CacheZip\7zr.exe" x "$($DownloadExtraResult.FullName)" -o"$CacheZip\7za" -y
    }

    if ($Architecture -eq 'amd64') {
        Copy-Item -Path "$CacheZip\7za\x64\*" -Destination "$MountPath\Windows\System32" -Recurse -Force
        
        # Record the installed app
        $global:BuildMedia.InstalledApps += $AppName
    }
    if ($Architecture -eq 'arm64') {
        Copy-Item -Path "$CacheZip\7za\arm64\*" -Destination "$MountPath\Windows\System32" -Recurse -Force
        
        # Record the installed app
        $global:BuildMedia.InstalledApps += $AppName
    }
    #=================================================
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}