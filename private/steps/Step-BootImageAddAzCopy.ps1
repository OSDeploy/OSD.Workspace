function Step-BootImageAddAzCopy {
    [CmdletBinding()]
    param (
        [System.String]
        $MountPath = $global:BuildMedia.MountPath,
        $OSDWorkspaceCachePath = $global:BuildMedia.OSDCachePath,
        $Architecture = $global:BuildMedia.Architecture
    )
    # Get started with AzCopy
    # https://learn.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-v10?tabs=dnf
    $global:BuildMedia.AddAzCopy = $false

    $CacheAzCopy = Join-Path $OSDWorkspaceCachePath "BootImage-AzCopy"
    if (-not (Test-Path -Path $CacheAzCopy)) {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] AzCopy: Adding cache content at $CacheAzCopy"
        New-Item -Path $CacheAzCopy -ItemType Directory -Force | Out-Null
    }
    else {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] AzCopy: Using cache content at $CacheAzCopy"
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] To update AzCopy, delete the $CacheAzCopy directory."
    }

    # amd64
    if (-not (Test-Path "$CacheAzCopy\amd64")) {
        $Uri = $global:OSDWorkspace.azcopy.amd64
        $DownloadUri = (Invoke-WebRequest -Uri $Uri -UseBasicParsing -MaximumRedirection 0 -ErrorAction SilentlyContinue).headers.location
        if ($DownloadUri) {
            $FileName = Split-Path $DownloadUri -Leaf
            if (-not (Test-Path "$CacheAzCopy\$FileName")) {
                $DownloadResult = Save-WebFile -SourceUrl $DownloadUri -DestinationDirectory $CacheAzCopy
                Start-Sleep -Seconds 2
                Expand-Archive -Path $($DownloadResult.FullName) -DestinationPath "$CacheAzCopy\amd64" -Force
            }
        }
    }

    # arm64
    if (-not (Test-Path "$CacheAzCopy\arm64")) {
        $Uri = $global:OSDWorkspace.azcopy.arm64
        $DownloadUri = (Invoke-WebRequest -Uri $Uri -UseBasicParsing -MaximumRedirection 0 -ErrorAction SilentlyContinue).headers.location
        if ($DownloadUri) {
            $FileName = Split-Path $DownloadUri -Leaf
            if (-not (Test-Path "$CacheAzCopy\$FileName")) {
                $DownloadResult = Save-WebFile -SourceUrl $DownloadUri -DestinationDirectory $CacheAzCopy
                Start-Sleep -Seconds 2
                Expand-Archive -Path $($DownloadResult.FullName) -DestinationPath "$CacheAzCopy\arm64" -Force
            }
        }
    }

    Get-ChildItem -Path "$CacheAzCopy\$Architecture" -Recurse -Include 'AzCopy.exe' -ErrorAction SilentlyContinue | ForEach-Object {
        Copy-Item $_.FullName -Destination "$MountPath\Windows\System32" -Force
        $global:BuildMedia.AddAzCopy = $true
    }
}