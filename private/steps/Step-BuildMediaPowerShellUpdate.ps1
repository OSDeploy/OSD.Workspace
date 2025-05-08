function Step-BuildMediaPowerShellUpdate {
    [CmdletBinding()]
    param (
        [System.String]
        $MountPath = $global:BuildMedia.MountPath,
        [System.String]
        $WSCachePath = $global:BuildMedia.WSCachePath,
        [System.String]
        $WimSourceType = $global:BuildMedia.WimSourceType
    )
    #=================================================
    $Error.Clear()
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Start"
    #=================================================
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] MountPath: $MountPath"
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] WSCachePath: $WSCachePath"
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] WimSourceType: $WimSourceType"
    #=================================================
$InfEnvironment = @'
[Version]
Signature   = "$WINDOWS NT$"
Class       = System
ClassGuid   = {4D36E97d-E325-11CE-BFC1-08002BE10318}
Provider    = OSDeploy
DriverVer   = 03/08/2021,2021.03.08.0

[DefaultInstall] 
AddReg      = AddReg 

[AddReg]
;rootkey,[subkey],[value],[flags],[data]
;0x00000    REG_SZ
;0x00001    REG_BINARY
;0x10000    REG_MULTI_SZ
;0x20000    REG_EXPAND_SZ
;0x10001    REG_DWORD
;0x20001    REG_NONE
HKLM,"SYSTEM\ControlSet001\Control\Session Manager\Environment",APPDATA,0x00000,"X:\Windows\System32\Config\SystemProfile\AppData\Roaming"
HKLM,"SYSTEM\ControlSet001\Control\Session Manager\Environment",HOMEDRIVE,0x00000,"X:"
HKLM,"SYSTEM\ControlSet001\Control\Session Manager\Environment",HOMEPATH,0x00000,"\Windows\System32\Config\SystemProfile"
HKLM,"SYSTEM\ControlSet001\Control\Session Manager\Environment",LOCALAPPDATA,0x00000,"X:\Windows\System32\Config\SystemProfile\AppData\Local"
'@
    #=================================================
    # Create these folders in the System Profile
    <#
    Desktop
    Documents
    Downloads
    Favorites
    Links
    Music
    Pictures
    Saved Games
    Videos
    #>
    #=================================================
    # Copy User Folders to the System Profile
    $null = robocopy.exe "$MountPath\Users\Default" "$MountPath\Windows\System32\Config\SystemProfile" *.* /e /b /ndl /nfl /np /ts /r:0 /w:0 /xj /xf NTUSER.*
    #=================================================
    # Get the Paths for this function
    $WinPEPSRepository = "$MountPath\Windows\Temp\psrepository"
    $CachePSRepository = $OSDWorkspace.paths.psrepository
    $CachePowerShellModules = $OSDWorkspace.paths.powershell_modules
    $MountedPSModulesPath = "$MountPath\Program Files\WindowsPowerShell\Modules"
    #=================================================
    # Create WinPE PSRepository folder
    if (-not (Test-Path -Path $WinPEPSRepository)) {
        New-Item -Path $WinPEPSRepository -ItemType Directory -Force | Out-Null
    }
    #=================================================
    # Create CachePSRepository folder
    if (-not (Test-Path -Path $CachePSRepository)) {
        New-Item -Path $CachePSRepository -ItemType Directory -Force | Out-Null
    }
    #=================================================
    # Is PackageManagement in the Cache?
    $PackageName = 'packagemanagement.1.4.8.1.nupkg'
    $PSRepositoryModule = Join-Path $CachePSRepository $PackageName
    # https://psg-prod-eastus.azureedge.net/packages/packagemanagement.1.4.8.1.nupkg
    #$PSModuleUrl = "https://www.powershellgallery.com/api/v2/package/PackageManagement/1.4.8.1/$PackageName"
    $PSModuleUrl = 'https://www.powershellgallery.com/api/v2/package/PackageManagement/1.4.8.1/#manualdownload'
    $PSModuleDestination = "$MountedPSModulesPath\PackageManagement\1.4.8.1"

    if (-not (Test-Path $PSRepositoryModule)) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Adding cache content $PSRepositoryModule"
        if (Get-Command 'curl.exe') {
            & curl.exe -L -o $PSRepositoryModule $PSModuleUrl
        }
        else {
            Invoke-WebRequest -UseBasicParsing -Uri $PSModuleUrl -OutFile $PSRepositoryModule
        }
    }
    #=================================================
    # Add PackageManagement to WinPE
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Using cache content $PSRepositoryModule"
    Expand-Archive -Path $PSRepositoryModule -DestinationPath $PSModuleDestination -Force
    $folderToDelete = "_rels"
    Remove-Item -Path "$PSModuleDestination\$folderToDelete" -Recurse -ErrorAction SilentlyContinue
    $folderToDelete2 = "package"
    Remove-Item -Path "$PSModuleDestination\$folderToDelete2" -Recurse -ErrorAction SilentlyContinue
    $fileToDelete = "$PackageName.nuspec"
    Remove-Item -Path "$PSModuleDestination\$fileToDelete" -Force -ErrorAction SilentlyContinue
    $fileToDelete2 = "`[Content_Types`].xml"
    Remove-Item -LiteralPath "$PSModuleDestination\$fileToDelete2" -Force -ErrorAction SilentlyContinue
    #=================================================
    # Is PowerShellGet in the Cache?
    $PackageName = 'powershellget.2.2.5.nupkg'
    $PSRepositoryModule = Join-Path $CachePSRepository $PackageName
    #'https://psg-prod-eastus.azureedge.net/packages/powershellget.2.2.5.nupkg'
    # $PSModuleUrl = "https://www.powershellgallery.com/api/v2/package/PowerShellGet/2.2.5/$PackageName"
    $PSModuleUrl = 'https://www.powershellgallery.com/api/v2/package/PowerShellGet/2.2.5/#manualdownload'
    $PSModuleDestination = "$MountedPSModulesPath\PowerShellGet\2.2.5"

    if (-not (Test-Path $PSRepositoryModule)) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Adding cache content $PSRepositoryModule"
        if (Get-Command 'curl.exe') {
            & curl.exe -L -o $PSRepositoryModule $PSModuleUrl
        }
        else {
            Invoke-WebRequest -UseBasicParsing -Uri $PSModuleUrl -OutFile $PSRepositoryModule
        }
    }
    #=================================================
    # Add PowerShellGet to WinPE
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Using cache content $PSRepositoryModule"
    Expand-Archive -Path $PSRepositoryModule -DestinationPath $PSModuleDestination -Force
    $folderToDelete = "_rels"
    Remove-Item -Path "$PSModuleDestination\$folderToDelete" -Recurse -ErrorAction SilentlyContinue
    $folderToDelete2 = "package"
    Remove-Item -Path "$PSModuleDestination\$folderToDelete2" -Recurse -ErrorAction SilentlyContinue
    $fileToDelete = "$PackageName.nuspec"
    Remove-Item -Path "$PSModuleDestination\$fileToDelete" -Force -ErrorAction SilentlyContinue
    $fileToDelete2 = "`[Content_Types`].xml"
    Remove-Item -LiteralPath "$PSModuleDestination\$fileToDelete2" -Force -ErrorAction SilentlyContinue
    #=================================================
    # Is NuGet.exe in the Cache?
    $PackageName = 'nuget.exe'
    $PSRepositoryModule = Join-Path $CachePSRepository $PackageName
    $PSModuleUrl = 'http://aka.ms/psget-nugetexe'
    $PSModuleDestination = "$MountPath\ProgramData\Microsoft\Windows\PowerShell\PowerShellGet"

    if (-not (Test-Path $PSRepositoryModule)) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Adding cache content $PSRepositoryModule"
        if (Get-Command 'curl.exe') {
            & curl.exe -L -o $PSRepositoryModule $PSModuleUrl
        }
        else {
            Invoke-WebRequest -UseBasicParsing -Uri $PSModuleUrl -OutFile $PSRepositoryModule
        }
    }
    #=================================================
    # Add NuGet.exe to WinPE
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Using cache content $PSRepositoryModule"
    if (-not (Test-Path $PSModuleDestination)) {
        New-Item -Path $PSModuleDestination -ItemType Directory -Force | Out-Null
    }
    Copy-Item -Path $PSRepositoryModule -Destination $PSModuleDestination -Force
    #=================================================
    # Populate WinPE PSRepository
    & robocopy.exe "$CachePSRepository" "$WinPEPSRepository" *.* /e /ndl /nfl /np /njh /njs /r:0 /w:0 /xj
    #=================================================
    # Add User Environment Variables to the System Profile
    & reg LOAD HKLM\Mount "$MountPath\Windows\System32\Config\DEFAULT"
    Start-Sleep -Seconds 3
    reg add "HKLM\Mount\Environment" /v Path /t REG_SZ /d "X:\Windows\System32\Config\SystemProfile\AppData\Local\Microsoft\WindowsApps" /f
    reg add "HKLM\Mount\Environment" /v TEMP /t REG_SZ /d "X:\Windows\Temp" /f
    reg add "HKLM\Mount\Environment" /v TMP /t REG_SZ /d "X:\Windows\Temp" /f
    Start-Sleep -Seconds 3
    & reg UNLOAD HKLM\Mount
    Start-Sleep -Seconds 3
    #=================================================
    # Add Environment Variable INF
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] PowerShell: Add Environment Variables"
    $InfFile = "$env:Temp\Set-WinPEEnvironment.inf"
    New-Item -Path $InfFile -Force | Out-Null
    Set-Content -Path $InfFile -Value $InfEnvironment -Encoding Unicode -Force
    $null = Add-WindowsDriver -Path $MountPath -Driver $InfFile -ForceUnsigned

    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] PowerShell: Set WinPE ExecutionPolicy to Bypass"
    Set-WindowsImageExecutionPolicy -Path $MountPath -ExecutionPolicy Bypass | Out-Null
    #=================================================
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}