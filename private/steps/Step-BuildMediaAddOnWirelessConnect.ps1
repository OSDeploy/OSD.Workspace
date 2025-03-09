function Step-BuildMediaAddOnWirelessConnect {
    [CmdletBinding()]
    param (
        [System.String]
        $Architecture = $global:BuildMedia.Architecture,
        [System.String]
        $MountPath = $global:BuildMedia.MountPath,
        [System.String]
        $WSCachePath = $global:BuildMedia.WSCachePath,
        [System.String]
        $WimSourceType = $global:BuildMedia.WimSourceType
    )
    #=================================================
    $Error.Clear()
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Architecture: $Architecture"
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] MountPath: $MountPath"
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] WSCachePath: $WSCachePath"
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] WimSourceType: $WimSourceType"
    #=================================================
    # WinRE Add WirelessConnect.exe
    # https://oliverkieselbach.com/
    # https://github.com/okieselbach/Helpers
    # https://msendpointmgr.com/2018/03/06/build-a-winpe-with-wireless-support/
    $global:BuildMedia.AddOnWirelessConnect = $false

    if ($WimSourceType -eq 'WinRE') {
        $CacheWirelessConnect = Join-Path $WSCachePath "AddOn-WirelessConnect"
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
            $global:BuildMedia.AddOnWirelessConnect = $true
        }
    }
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}