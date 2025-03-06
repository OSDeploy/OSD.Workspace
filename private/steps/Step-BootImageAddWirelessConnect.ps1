function Step-BootImageAddWirelessConnect {
    [CmdletBinding()]
    param (
        [System.String]
        $MountPath = $global:BootMedia.MountPath,
        $OSDWorkspaceCachePath = $global:BootMedia.OSDCachePath,
        $WimSourceType = $global:BootMedia.WimSourceType
    )
    # WinRE Add WirelessConnect.exe
    # https://oliverkieselbach.com/
    # https://github.com/okieselbach/Helpers
    # https://msendpointmgr.com/2018/03/06/build-a-winpe-with-wireless-support/
    $global:BootMedia.AddWirelessConnect = $false

    if ($WimSourceType -eq 'WinRE') {
        $CacheWirelessConnect = Join-Path $OSDWorkspaceCachePath "BootImage-WirelessConnect"
        $WirelessConnectExe = "$CacheWirelessConnect\WirelessConnect.exe"
        if (-not (Test-Path -Path $CacheWirelessConnect)) {
            Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Creating WirelessConnect cache at $CacheWirelessConnect"
            New-Item -Path $CacheWirelessConnect -ItemType Directory -Force | Out-Null
        }
        if (-not (Test-Path -Path $WirelessConnectExe)) {
            Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] WirelessConnect: Adding cache content at $CacheWirelessConnect"
            Save-WebFile -SourceUrl 'https://github.com/okieselbach/Helpers/raw/master/WirelessConnect/WirelessConnect/bin/Release/WirelessConnect.exe' -DestinationDirectory $CacheWirelessConnect | Out-Null
        }
        if (Test-Path $WirelessConnectExe) {
            Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] WirelessConnect: Using cache content at $WirelessConnectExe"
            Copy-Item -Path $WirelessConnectExe -Destination "$MountPath\Windows\System32\WirelessConnect.exe" -Force | Out-Null
            $global:BootMedia.AddWirelessConnect = $true
        }
    }
}