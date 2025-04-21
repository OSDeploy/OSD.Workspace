function Step-WinPEAppAzCopy {
    [CmdletBinding()]
    param (
        [System.String]
        $AppName = 'AzCopy',
        [System.String]
        $Architecture = $global:BuildMedia.Architecture,
        [System.String]
        $MountPath = $global:BuildMedia.MountPath,
        [System.String]
        $WinPEAppsPath = $($OSDWorkspace.paths.winpe_apps)
    )
    #=================================================
    $Error.Clear()
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Start"
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Architecture: $Architecture"
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] MountPath: $MountPath"
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] WinPEAppsPath: $WinPEAppsPath"
    #=================================================
    # Get started with AzCopy
    # https://learn.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-v10?tabs=dnf

    $CacheAzCopy = Join-Path $WinPEAppsPath 'AzCopy'

    if (-not (Test-Path -Path $CacheAzCopy)) {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Adding cache content $CacheAzCopy"
        New-Item -Path $CacheAzCopy -ItemType Directory -Force | Out-Null
    }
    else {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Using cache content $CacheAzCopy"
    }

    # amd64
    if (-not (Test-Path "$CacheAzCopy\amd64")) {
        $Uri = $global:OSDWorkspace.winpeapps.azcopy.amd64
        #$DownloadUri = (Invoke-WebRequest -Uri $Uri -Method Head -ErrorAction SilentlyContinue).headers.location
        $DownloadUri = (Invoke-WebRequest -Uri $Uri -Method Head -ErrorAction SilentlyContinue).BaseResponse.RequestMessage.RequestUri.AbsoluteUri
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
        $Uri = $global:OSDWorkspace.winpeapps.azcopy.arm64
        # $DownloadUri = (Invoke-WebRequest -Uri $Uri -UseBasicParsing -Method Head -ErrorAction SilentlyContinue).headers.location
        $DownloadUri = (Invoke-WebRequest -Uri $Uri -Method Head -ErrorAction SilentlyContinue).BaseResponse.RequestMessage.RequestUri.AbsoluteUri
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
        
        # Record the installed app
        $global:BuildMedia.InstalledApps += $AppName
    }
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}