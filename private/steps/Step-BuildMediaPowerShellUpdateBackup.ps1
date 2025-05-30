function Step-BuildMediaPowerShellUpdateBackup {
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
    $CachePSRepository = $OSDWorkspace.paths.psrepository
    $CachePowerShellModules = $OSDWorkspace.paths.powershell_modules
    $MountedPSModulesPath = "$MountPath\Program Files\WindowsPowerShell\Modules"
    #=================================================
    # Make sure the OSDWorkspace machine has Nuget installed
    #=================================================
    <#
    # Make sure to Unregister-PSRepository -Name OSDWorkspace
    # PackageManagement
    $PackageManagementLatestLocallyAvailableVersion = $($(Get-Module -ListAvailable | Where-Object { $_.Name -eq "PackageManagement" }).Version | Measure-Object -Maximum).Maximum
    
    # PowerShellGet
    $PowerShellGetLatestLocallyAvailableVersion = $($(Get-Module -ListAvailable | Where-Object { $_.Name -eq "PowerShellGet" }).Version | Measure-Object -Maximum).Maximum

    # References
    # https://github.com/KurtDeGreeff/misc-powershell/blob/3d5c7d3485b01baea5326111b998cc3e3fb05bb1/Update-PackageManagement.ps1#L8
    # https://github.com/maxisam/misc-powershell/blob/93f9ff390533ddbb13aa991e27613c7a140dab1f/MyModules/WinSSH/WinSSH.psm1#L1140
    #>
    #=================================================
    # Get Names of the mounted PowerShell modules
    $MountedPSModules = Get-ChildItem -Path $MountedPSModulesPath -ErrorAction SilentlyContinue | Where-Object { $_.PSIsContainer -eq $true } | Select-Object -ExpandProperty Name

    foreach ($Name in $MountedPSModules) {
        if (($Name -eq 'Microsoft.PowerShell.Operation.Validation') -or ($Name -eq 'Pester') -or ($Name -eq 'PSReadLine')) {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)][$($MyInvocation.MyCommand.Name)] PowerShell Module $Name does not require an update"
            continue
        }

        if ($Name -eq 'PackageManagement') {
            Register-PSRepository -Name OSDWorkspace -SourceLocation $CachePSRepository -PublishLocation $CachePSRepository -InstallationPolicy Trusted
            
            try {
                Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)][$($MyInvocation.MyCommand.Name)] Save-Module -Name $Name -Path `"$MountedPSModulesPath`" -Force"
                Save-Module -Name $Name -Path "$MountedPSModulesPath" -Repository OSDWorkspace -Force -ErrorAction Stop
            }
            catch {
                Write-Warning "[$(Get-Date -format G)][$($MyInvocation.MyCommand.Name)] Save-Module failed: $Name"
            }
            Unregister-PSRepository -Name OSDWorkspace -ErrorAction SilentlyContinue
            continue
        }

        if ($Name -eq 'PowerShellGet') {
            Register-PSRepository -Name OSDWorkspace -SourceLocation $CachePSRepository -PublishLocation $CachePSRepository -InstallationPolicy Trusted
            
            try {
                Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)][$($MyInvocation.MyCommand.Name)] Save-Module -Name $Name -Path `"$MountedPSModulesPath`" -Force"
                Save-Module -Name $Name -Path "$MountedPSModulesPath" -Repository OSDWorkspace -Force -ErrorAction Stop
            }
            catch {
                Write-Warning "[$(Get-Date -format G)][$($MyInvocation.MyCommand.Name)] Save-Module failed: $Name"
            }
            Unregister-PSRepository -Name OSDWorkspace -ErrorAction SilentlyContinue
            continue
        }
        
        Register-PSRepository -Name OSDWorkspace -SourceLocation $CachePSRepository -PublishLocation $CachePSRepository -InstallationPolicy Trusted
        $FindModule = Find-Module -Name $Name -ErrorAction SilentlyContinue
        if ($null -eq $FindModule) {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)][$($MyInvocation.MyCommand.Name)] PowerShell Module $Name was not found in PSGallery or OSDWorkspace"
            Unregister-PSRepository -Name OSDWorkspace -ErrorAction SilentlyContinue
            continue
        }

        try {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)][$($MyInvocation.MyCommand.Name)] Save-Module -Name $Name -Path `"$MountedPSModulesPath`" -Force"
            Save-Module -Name $Name -Path "$MountedPSModulesPath" -Force -ErrorAction Stop
        }
        catch {
            Write-Warning "[$(Get-Date -format G)][$($MyInvocation.MyCommand.Name)] Save-Module failed: $Name"
        }
        Unregister-PSRepository -Name OSDWorkspace -ErrorAction SilentlyContinue
    }

    <#
    $ModuleNames = @('PackageManagement', 'PowerShellGet', 'Microsoft.PowerShell.PSResourceGet')
    $ModuleNames | ForEach-Object {
        $ModuleName = $_
        if (-not (Test-Path -Path "$CachePowerShellModules\$ModuleName")) {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Updating PowerShell Module cache at $CachePowerShellModules\$ModuleName"
            #Save-Module -Name $ModuleName -Path $CachePowerShellModules -Repository PSGallery -Force -ErrorAction SilentlyContinue
        }
        if (Test-Path -Path "$CachePowerShellModules\$ModuleName") {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Adding PowerShell Module at $MountedPSModulesPath\$ModuleName"
            #Copy-Item -Path "$CachePowerShellModules\$ModuleName" -Destination $MountedPSModulesPath -Recurse -Force
        }
    }
    #>
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