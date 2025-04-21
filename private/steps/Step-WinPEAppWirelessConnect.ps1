function Step-WinPEAppWirelessConnect {
    [CmdletBinding()]
    param (
        [System.String]
        $AppName = 'WirelessConnect',
        [System.String]
        $Architecture = $global:BuildMedia.Architecture,
        [System.String]
        $MountPath = $global:BuildMedia.MountPath,
        [System.String]
        $WinPEAppsPath = $($OSDWorkspace.paths.winpe_apps),
        [System.String]
        $WimSourceType = $global:BuildMedia.WimSourceType
    )
    #=================================================
    $Error.Clear()
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Start"
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Architecture: $Architecture"
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] MountPath: $MountPath"
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] WinPEAppsPath: $WinPEAppsPath"
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] WimSourceType: $WimSourceType"
    #=================================================
    # WinRE Add WirelessConnect.exe
    # https://oliverkieselbach.com/
    # https://github.com/okieselbach/Helpers
    # https://msendpointmgr.com/2018/03/06/build-a-winpe-with-wireless-support/

    if ($WimSourceType -eq 'WinRE') {
        $CacheWirelessConnect = Join-Path $WinPEAppsPath "WirelessConnect"
        
        $WirelessConnectExe = "$CacheWirelessConnect\WirelessConnect.exe"
        if (-not (Test-Path -Path $CacheWirelessConnect)) {
            New-Item -Path $CacheWirelessConnect -ItemType Directory -Force | Out-Null
        }
        if (-not (Test-Path -Path $WirelessConnectExe)) {
            Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Adding cache content $CacheWirelessConnect"
            Save-WebFile -SourceUrl 'https://github.com/okieselbach/Helpers/raw/master/WirelessConnect/WirelessConnect/bin/Release/WirelessConnect.exe' -DestinationDirectory $CacheWirelessConnect | Out-Null
        }
        if (Test-Path $WirelessConnectExe) {
            Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Using cache content $WirelessConnectExe"
            Copy-Item -Path $WirelessConnectExe -Destination "$MountPath\Windows\System32\WirelessConnect.exe" -Force | Out-Null
            
            # Record the installed app
            $global:BuildMedia.InstalledApps += $AppName
        }
    }
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}