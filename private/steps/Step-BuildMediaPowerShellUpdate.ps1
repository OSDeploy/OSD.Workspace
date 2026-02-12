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
    # Copy User Folders to the System Profile
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Copy User Folders to the System Profile"
    $null = robocopy.exe "$MountPath\Users\Default" "$MountPath\Windows\System32\Config\SystemProfile" *.* /e /b /ndl /nfl /np /ts /r:0 /w:0 /xj /xf NTUSER.*
    #=================================================
    # Create Required Folders
    $requiredFolders = @(
        "$MountPath\Program Files\WindowsPowerShell\Modules",
        "$MountPath\Program Files\WindowsPowerShell\Scripts",
        "$MountPath\Users\Default\AppData\Local",
        "$MountPath\Users\Default\AppData\Roaming",
        "$MountPath\Users\Default\Desktop",
        "$MountPath\Users\Default\Documents\WindowsPowerShell",
        "$MountPath\Windows\System32\WindowsPowerShell\v1.0\Modules",
        "$MountPath\Windows\System32\WindowsPowerShell\v1.0\Scripts"
    )
    foreach ($item in $requiredFolders) {
        if (-not (Test-Path -Path $item)) {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Creating $item"
            New-Item -Path $item -ItemType Directory -Force | Out-Null
        }
    }
    #=================================================
    # WinPE PSRepository
    $CachePSRepository = $OSDWorkspace.paths.psrepository
    if (-not (Test-Path -Path $CachePSRepository)) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Creating $CachePSRepository"
        New-Item -Path $CachePSRepository -ItemType Directory -Force | Out-Null
    }
    $WinPEPSRepository = "$MountPath\Windows\Temp\psrepository"
    if (-not (Test-Path -Path $WinPEPSRepository)) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Creating $WinPEPSRepository"
        New-Item -Path $WinPEPSRepository -ItemType Directory -Force | Out-Null
    }
    $MountedPSModulesPath = "$MountPath\Program Files\WindowsPowerShell\Modules"
    # $CachePowerShellModules = $OSDWorkspace.paths.powershell_modules
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
    # $PSModuleDestination = "$MountPath\ProgramData\Microsoft\Windows\PowerShell\PowerShellGet"
    $PSModuleDestination = "$MountPath\Windows\System32\Config\SystemProfile\AppData\Local\Microsoft\Windows\PowerShell\PowerShellGet"
    if (-not (Test-Path $PSModuleDestination)) {
        New-Item -Path $PSModuleDestination -ItemType Directory -Force | Out-Null
    }
    Copy-Item -Path $PSRepositoryModule -Destination $PSModuleDestination -Force
    #=================================================
    # Create PSRepositories.xml and Trust PSGallery
    $PSRepositoriesContent = @'
<Objs Version="1.1.0.1" xmlns="http://schemas.microsoft.com/powershell/2004/04">
  <Obj RefId="0">
    <TN RefId="0">
      <T>System.Collections.Hashtable</T>
      <T>System.Object</T>
    </TN>
    <DCT>
      <En>
        <S N="Key">PSGallery</S>
        <Obj N="Value" RefId="1">
          <TN RefId="1">
            <T>Microsoft.PowerShell.Commands.PSRepository</T>
            <T>System.Management.Automation.PSCustomObject</T>
            <T>System.Object</T>
          </TN>
          <MS>
            <S N="Name">PSGallery</S>
            <S N="SourceLocation">https://www.powershellgallery.com/api/v2</S>
            <S N="PublishLocation">https://www.powershellgallery.com/api/v2/package/</S>
            <S N="ScriptSourceLocation">https://www.powershellgallery.com/api/v2/items/psscript</S>
            <S N="ScriptPublishLocation">https://www.powershellgallery.com/api/v2/package/</S>
            <Obj N="Trusted" RefId="2">
              <TN RefId="2">
                <T>System.Management.Automation.SwitchParameter</T>
                <T>System.ValueType</T>
                <T>System.Object</T>
              </TN>
              <ToString>True</ToString>
              <Props>
                <B N="IsPresent">true</B>
              </Props>
            </Obj>
            <B N="Registered">true</B>
            <S N="InstallationPolicy">Trusted</S>
            <S N="PackageManagementProvider">NuGet</S>
            <Obj N="ProviderOptions" RefId="3">
              <TNRef RefId="0" />
              <DCT />
            </Obj>
          </MS>
        </Obj>
      </En>
    </DCT>
  </Obj>
</Objs>
'@

    $PSRepositoriesFile = "$MountPath\Windows\System32\Config\SystemProfile\AppData\Local\Microsoft\Windows\PowerShell\PowerShellGet\PSRepositories.xml"
    if (-NOT (Test-Path -Path $PSRepositoriesFile)) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Create PSRepositories.xml and Trust PSGallery"
        $PSRepositoriesContent | Set-Content -Path $PSRepositoriesFile -Encoding utf8 -Force
    }
    #=================================================
    # Create PowerShell Profile
    $PowerShellProfileContent = @'
# OSD PowerShell Profile
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
$registryPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment'
$registryPath | ForEach-Object {
    $k = Get-Item $_
    $k.GetValueNames() | ForEach-Object {
        $name = $_
        $value = $k.GetValue($_)
        Set-Item -Path Env:\$name -Value $value
    }
}
'@
    $PowerShellProfileFile = "$MountPath\Windows\System32\WindowsPowerShell\v1.0\profile.ps1"
    if (-NOT (Test-Path -Path $PowerShellProfileFile)) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Create OSD PowerShell Profile"
        $PowerShellProfileContent | Set-Content -Path $PowerShellProfileFile -Encoding utf8 -Force
    }
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
    # Set WinPE Environment Variables
$InfEnvironment = @'
[Version]
Signature   = "$WINDOWS NT$"
Class       = System
ClassGuid   = {4D36E97d-E325-11CE-BFC1-08002BE10318}
Provider    = OSDeploy
DriverVer   = 01/29/2026,2026.01.29.0

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
HKLM,"SYSTEM\ControlSet001\Control\Session Manager\Environment",USERDATA,0x00000,"X:\Windows\System32\Config\SystemProfile"
'@
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] PowerShell: Set WinPE Environment Variables"
    $InfFile = "$env:Temp\Set-WinPEEnvironment.inf"
    New-Item -Path $InfFile -Force | Out-Null
    Set-Content -Path $InfFile -Value $InfEnvironment -Encoding Unicode -Force
    $null = Add-WindowsDriver -Path $MountPath -Driver $InfFile -ForceUnsigned
    #=================================================
    # Set WinPE PowerShell Execution Policy
$InfExecutionPolicy = @'
[Version]
Signature   = "$WINDOWS NT$"
Class       = System
ClassGuid   = {4D36E97d-E325-11CE-BFC1-08002BE10318}
Provider    = OSDeploy
DriverVer   = 01/29/2026,2026.01.29.0

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
HKLM,SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell,ExecutionPolicy,0x00000,"Bypass"
'@
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] PowerShell: Set WinPE PowerShell Execution Policy"
    $InfFile = "$env:Temp\Set-WinPEExecutionPolicy.inf"
    New-Item -Path $InfFile -Force | Out-Null
    Set-Content -Path $InfFile -Value $InfExecutionPolicy -Encoding Unicode -Force
    $null = Add-WindowsDriver -Path $MountPath -Driver $InfFile -ForceUnsigned
    #=================================================
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}