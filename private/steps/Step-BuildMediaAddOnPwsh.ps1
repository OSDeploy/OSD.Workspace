function Step-BuildMediaAddOnPwsh {
    [CmdletBinding()]
    param (
        [System.String]
        $Architecture = $global:BuildMedia.Architecture,
        [System.String]
        $MountPath = $global:BuildMedia.MountPath,
        [System.String]
        $WSAddOnPackagesPath = $(Get-OSDWSAddOnPackagesPath)
    )
    #=================================================
    $Error.Clear()
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Architecture: $Architecture"
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] MountPath: $MountPath"
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] WSAddOnPackagesPath: $WSAddOnPackagesPath"
    #=================================================
    $global:BuildMedia.AddOnPwsh = $false
    $CachePowerShell7 = Join-Path $WSAddOnPackagesPath "Pwsh"
    
    if (-not (Test-Path -Path $CachePowerShell7)) {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] PowerShell 7: Adding cache content at $CachePowerShell7"
        New-Item -Path $CachePowerShell7 -ItemType Directory -Force | Out-Null
    }
    else {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] PowerShell 7: Using cache content at $CachePowerShell7"
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] To update PowerShell 7, delete the $CachePowerShell7 directory."
    }

    # Download amd64
    $DownloadUri = $global:OSDWorkspace.pwsh.amd64
    $DownloadFile = Split-Path $DownloadUri -Leaf
    if (-not (Test-Path "$CachePowerShell7\$DownloadFile")) {
        $DownloadResult = Save-WebFile -SourceUrl $DownloadUri -DestinationDirectory $CachePowerShell7
        Start-Sleep -Seconds 2
    }
    # Install amd64
    if ($Architecture -eq 'amd64') {
        if (Test-Path "$CachePowerShell7\$DownloadFile") {
            Expand-Archive -Path "$CachePowerShell7\$DownloadFile" -DestinationPath "$MountPath\Program Files\PowerShell\7" -Force
            $global:BuildMedia.AddOnPwsh = (Get-Item -Path "$CachePowerShell7\$DownloadFile").BaseName
        }
    }

    # Download arm64
    $DownloadUri = $global:OSDWorkspace.pwsh.arm64
    $DownloadFile = Split-Path $DownloadUri -Leaf
    if (-not (Test-Path "$CachePowerShell7\$DownloadFile")) {
        $DownloadResult = Save-WebFile -SourceUrl $DownloadUri -DestinationDirectory $CachePowerShell7
        Start-Sleep -Seconds 2
        if ($Architecture -eq 'arm64') {
            Expand-Archive -Path "$CachePowerShell7\$DownloadFile" -DestinationPath "$MountPath\Program Files\PowerShell\7" -Force
        }
    }
    # Install arm64
    if ($Architecture -eq 'arm64') {
        if (Test-Path "$CachePowerShell7\$DownloadFile") {
            Expand-Archive -Path "$CachePowerShell7\$DownloadFile" -DestinationPath "$MountPath\Program Files\PowerShell\7" -Force
            $global:BuildMedia.AddOnPwsh = (Get-Item -Path "$CachePowerShell7\$DownloadFile").BaseName
        }
    }

    # Add PowerShell 7 PATH to WinPE ... Thanks Johan Arwidmark
    Invoke-Exe reg load HKLM\Mount "$MountPath\Windows\System32\Config\SYSTEM"
    Start-Sleep -Seconds 3
    $RegistryKey = 'HKLM:\Mount\ControlSet001\Control\Session Manager\Environment'
    $CurrentPath = (Get-Item -path $RegistryKey ).GetValue('Path', '', 'DoNotExpandEnvironmentNames')
    $NewPath = $CurrentPath + ';%ProgramFiles%\PowerShell\7\'
    $Result = New-ItemProperty -Path $RegistryKey -Name 'Path' -PropertyType ExpandString -Value $NewPath -Force 

    $CurrentPSModulePath = (Get-Item -path $RegistryKey ).GetValue('PSModulePath', '', 'DoNotExpandEnvironmentNames')
    $NewPSModulePath = $CurrentPSModulePath + ';%ProgramFiles%\PowerShell\;%ProgramFiles%\PowerShell\7\;%SystemRoot%\system32\config\systemprofile\Documents\PowerShell\Modules\'
    $Result = New-ItemProperty -Path $RegistryKey -Name 'PSModulePath' -PropertyType ExpandString -Value $NewPSModulePath -Force

    Get-Variable Result | Remove-Variable
    Get-Variable RegistryKey | Remove-Variable
    [gc]::collect()
    Start-Sleep -Seconds 3
    Invoke-Exe reg unload HKLM\Mount | Out-Null
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}