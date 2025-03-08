function Step-BootImageAddMicrosoftDart {
    [CmdletBinding()]
    param (
        [System.String]
        $MountPath = $global:BuildMedia.MountPath,
        $OSDWorkspaceCachePath = $global:BuildMedia.OSDCachePath
    )
    $global:BuildMedia.AddMicrosoftDaRT = $false

    $CacheMicrosoftDaRT = Join-Path $OSDWorkspaceCachePath 'BootImage-MicrosoftDaRT'

    # MicrosoftDartCab
    $MicrosoftDartCab = "$env:ProgramFiles\Microsoft DaRT\v10\Toolsx64.cab"
    if (Test-Path $MicrosoftDartCab) {
        if (-not (Test-Path "$CacheMicrosoftDaRT\Toolsx64.cab")) {
            Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Microsoft DaRT: Adding cache content at $CacheMicrosoftDaRT"
            if (-not (Test-Path $CacheMicrosoftDaRT)) {
                New-Item -Path $CacheMicrosoftDaRT -ItemType Directory -Force | Out-Null
            }
            Copy-Item -Path $MicrosoftDartCab -Destination "$CacheMicrosoftDaRT\Toolsx64.cab" -Force | Out-Null
        }
    }

    $MicrosoftDartCab = "$CacheMicrosoftDaRT\Toolsx64.cab"
    if (Test-Path $MicrosoftDartCab) {
        if ($BuildMediaName -match 'public') {
            Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Microsoft DaRT: Not adding Microsoft DaRT for Public BootMedia"
        }
        else {
            Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Microsoft DaRT: Using cache content at $MicrosoftDartCab"
            expand.exe "$MicrosoftDartCab" -F:*.* "$MountPath" | Out-Null
            $global:BuildMedia.AddMicrosoftDaRT = $true
        }
    }
    else {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Microsoft DaRT: Install Microsoft Desktop Optimization Pack to add Microsoft DaRT to BootImage"
    }

    # MicrosoftDartConfig
    $MicrosoftDartConfig = "$env:ProgramFiles\Microsoft Deployment Toolkit\Templates\DartConfig8.dat"
    if (Test-Path $MicrosoftDartConfig) {
        if (-not (Test-Path "$CacheMicrosoftDaRT\DartConfig.dat")) {
            Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Microsoft DaRT Config: Adding cache content at $CacheMicrosoftDaRT"
            if (-not (Test-Path $CacheMicrosoftDaRT)) {
                New-Item -Path $CacheMicrosoftDaRT -ItemType Directory -Force | Out-Null
            }
            Copy-Item -Path $MicrosoftDartConfig -Destination "$CacheMicrosoftDaRT\DartConfig.dat" -Force | Out-Null
        }
    }

    $MicrosoftDartConfig = "$CacheMicrosoftDaRT\DartConfig.dat"
    if (Test-Path "$MicrosoftDartConfig") {
        Copy-Item -Path "$MicrosoftDartConfig" -Destination "$MountPath\Windows\System32\DartConfig.dat" -Force
    }
    else {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Microsoft DaRT: Install Microsoft Deployment Toolkit to add Microsoft DaRT Config to BootImage"
    }
}