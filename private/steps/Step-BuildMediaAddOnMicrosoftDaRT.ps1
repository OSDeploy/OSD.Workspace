function Step-WinPEAppMicrosoftDaRT {
    [CmdletBinding()]
    param (
        [System.String]
        $AppName = 'Microsoft DaRT',
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
    $CacheMicrosoftDaRT = Join-Path $WinPEAppsPath 'MicrosoftDaRT'

    # MicrosoftDartCab
    $MicrosoftDartCab = "$env:ProgramFiles\Microsoft DaRT\v10\Toolsx64.cab"
    if (Test-Path $MicrosoftDartCab) {
        if (-not (Test-Path "$CacheMicrosoftDaRT\Toolsx64.cab")) {
            Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Microsoft DaRT: Adding cache content at $CacheMicrosoftDaRT"
            if (-not (Test-Path $CacheMicrosoftDaRT)) {
                New-Item -Path $CacheMicrosoftDaRT -ItemType Directory -Force | Out-Null
            }
            Copy-Item -Path $MicrosoftDartCab -Destination "$CacheMicrosoftDaRT\Toolsx64.cab" -Force | Out-Null
        }
    }

    $MicrosoftDartCab = "$CacheMicrosoftDaRT\Toolsx64.cab"
    if (Test-Path $MicrosoftDartCab) {
        if ($MediaName -match 'public') {
            Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Microsoft DaRT: Not adding Microsoft DaRT for Public BootMedia"
        }
        else {
            Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Microsoft DaRT: Using cache content at $MicrosoftDartCab"
            expand.exe "$MicrosoftDartCab" -F:*.* "$MountPath" | Out-Null
        
            # Record the installed app
            $global:BuildMedia.InstalledApps += $AppName
        }
    }
    else {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Microsoft DaRT: Install Microsoft Desktop Optimization Pack to add Microsoft DaRT to BootImage"
    }

    # MicrosoftDartConfig
    $MicrosoftDartConfig = "$env:ProgramFiles\Microsoft Deployment Toolkit\Templates\DartConfig8.dat"
    if (Test-Path $MicrosoftDartConfig) {
        if (-not (Test-Path "$CacheMicrosoftDaRT\DartConfig.dat")) {
            Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Microsoft DaRT Config: Adding cache content at $CacheMicrosoftDaRT"
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
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Microsoft DaRT: Install Microsoft Deployment Toolkit to add Microsoft DaRT Config to BootImage"
    }
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}