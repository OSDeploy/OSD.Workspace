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
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] MountPath: $MountPath"
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] WSCachePath: $WSCachePath"
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] WimSourceType: $WimSourceType"
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
HKLM,"SYSTEM\ControlSet001\Control\Session Manager\Environment",HOMEPATH,0x00000,"Windows\System32\Config\SystemProfile"
HKLM,"SYSTEM\ControlSet001\Control\Session Manager\Environment",LOCALAPPDATA,0x00000,"X:\Windows\System32\Config\SystemProfile\AppData\Local"
'@
    #=================================================
    $CachePowerShellModules = $OSDWorkspace.paths.powershell_modules
    $PSModulesPath = "$MountPath\Program Files\WindowsPowerShell\Modules"

    $ModuleNames = @('PackageManagement', 'PowerShellGet', 'Microsoft.PowerShell.PSResourceGet')
    $ModuleNames | ForEach-Object {
        $ModuleName = $_
        if (-not (Test-Path -Path "$CachePowerShellModules\$ModuleName")) {
            Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Updating PowerShell Module cache at $CachePowerShellModules\$ModuleName"
            Save-Module -Name $ModuleName -Path $CachePowerShellModules -Repository PSGallery -Force -ErrorAction SilentlyContinue
        }
        if (Test-Path -Path "$CachePowerShellModules\$ModuleName") {
            Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Adding PowerShell Module at $PSModulesPath\$ModuleName"
            Copy-Item -Path "$CachePowerShellModules\$ModuleName" -Destination $PSModulesPath -Recurse -Force
        }
    }

    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] PowerShell: Add Environment Variables"
    $InfFile = "$env:Temp\Set-WinPEEnvironment.inf"
    New-Item -Path $InfFile -Force | Out-Null
    Set-Content -Path $InfFile -Value $InfEnvironment -Encoding Unicode -Force
    $null = Add-WindowsDriver -Path $MountPath -Driver $InfFile -ForceUnsigned

    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] PowerShell: Set WinPE ExecutionPolicy to Bypass"
    Set-WindowsImageExecutionPolicy -Path $MountPath -ExecutionPolicy Bypass | Out-Null
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}