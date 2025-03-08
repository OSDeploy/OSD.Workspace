function Step-BootImageAddZip {
    [CmdletBinding()]
    param (
        [System.String]
        $MountPath = $global:BuildMedia.MountPath,
        $OSDWorkspaceCachePath = $global:BuildMedia.OSDCachePath,
        $Architecture = $global:BuildMedia.Architecture
    )
    # Thanks Gary Blok
    $global:BuildMedia.AddZip = $false
    $CacheZip = Join-Path $OSDWorkspaceCachePath "BootImage-7zip"
    if (-not (Test-Path -Path $CacheZip)) {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] 7zip: Adding cache content at $CacheZip"
        New-Item -Path $CacheZip -ItemType Directory -Force | Out-Null
    }
    else {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] 7zip: Using cache content at $CacheZip"
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] To update 7zip, delete the $CacheZip directory."
    }

    if (-not (Test-Path -Path "$CacheZip\7zr.exe")) {
        $DownloadStandalone = $global:OSDWorkspace.sevenzip.standalone
        Save-WebFile -SourceUrl $DownloadStandalone -DestinationDirectory $CacheZip
    }

    if (-not (Test-Path -Path "$CacheZip\7za")) {
        $DownloadExtra = $global:OSDWorkspace.sevenzip.extra
        $DownloadExtraResult = Save-WebFile -SourceUrl $DownloadExtra -DestinationDirectory $CacheZip
        $null = & "$CacheZip\7zr.exe" x "$($DownloadExtraResult.FullName)" -o"$CacheZip\7za" -y
    }

    if ($Architecture -eq 'amd64') {
        Copy-Item -Path "$CacheZip\7za\x64\*" -Destination "$MountPath\Windows\System32" -Recurse -Force
        $global:BuildMedia.AddZip = $true
    }
    if ($Architecture -eq 'arm64') {
        Copy-Item -Path "$CacheZip\7za\arm64\*" -Destination "$MountPath\Windows\System32" -Recurse -Force
        $global:BuildMedia.AddZip = $true
    }
}