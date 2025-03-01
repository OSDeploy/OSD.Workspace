function New-OSDWorkspaceBootMedia {
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param (
        # Name to append to the BootMedia Id
        [Parameter(Mandatory)]
        [System.String]
        $Name,

        [ValidateSet (
            '*','ar-sa','bg-bg','cs-cz','da-dk','de-de','el-gr',
            'en-gb','es-es','es-mx','et-ee','fi-fi',
            'fr-ca','fr-fr','he-il','hr-hr','hu-hu','it-it',
            'ja-jp','ko-kr','lt-lt','lv-lv','nb-no','nl-nl',
            'pl-pl','pt-br','pt-pt','ro-ro','ru-ru','sk-sk',
            'sl-si','sr-latn-rs','sv-se','th-th','tr-tr',
            'uk-ua','zh-cn','zh-tw'
        )]
        [System.String[]]
        #Windows ADK Languages to add to the BootImage. Default is en-US.
        $Languages = 'en-US',

        [System.String]
        #Sets all International settings in WinPE to the specified language. Default is en-US.
        $SetAllIntl = 'en-US',

        [System.String]
        #Sets the default InputLocale in WinPE to the specified Input Locale. Default is en-US.
        $SetInputLocale = 'en-US',

        [ValidateScript( {
                $tz = (tzutil /l)
                $validoptions = foreach ($t in $tz) { 
                    if (($tz.IndexOf($t) - 1) % 3 -eq 0) {
                        $t.Trim()
                    }
                }

                $validoptions -contains $_
            })]
        [System.String]
        #Set the WinPE TimeZone. Default is the current TimeZone.
        $Timezone = (tzutil /g),

        [System.Management.Automation.SwitchParameter]
        #Select the Windows ADK version to use if multiple versions are present in the cache.
        $AdkSelect,

        # Skip adding the Windows ADK Optional Components. Useful for quick testing of the Library.
        [System.Management.Automation.SwitchParameter]
        $AdkSkipOCs,

        [Parameter(Mandatory, ParameterSetName = 'ADK')]
        [System.Management.Automation.SwitchParameter]
        #Uses the Windows ADK winpe.wim instead of an imported BootImage.
        $AdkWinPE,

        [Parameter(ParameterSetName = 'Default')]
        [Parameter(Mandatory, ParameterSetName = 'ADK')]
        [ValidateSet('amd64', 'arm64')]
        [System.String]
        #Architecture of the BootImage. This is automatically set when selected a existing BootImage. This is required when using the Windows ADK winpe.wim.
        $Architecture,

        [System.Management.Automation.SwitchParameter]
        $UpdateUSB
    )
    #=================================================
    $Error.Clear()
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"

    $IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $IsAdmin ) {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] must be run with Administrator privileges"
        Break
    }
    #=================================================
    #region InfWinpeJpg
$InfWinpeJpg = @'
[Version]
Signature   = "$WINDOWS NT$"
Class       = System
ClassGuid   = {4D36E97d-E325-11CE-BFC1-08002BE10318}
Provider    = OSDeploy
DriverVer   = 07/20/2021,2021.07.20.0

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
HKLM,"Software\Microsoft\Windows NT\CurrentVersion\WinPE",CustomBackground,0x10000,"X:\Windows\System32\winpe.jpg"
'@
    #endregion
    #=================================================
    #region RegConsole
$RegConsole = @'
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\Default\Console]
"ColorTable00"=dword:000c0c0c
"ColorTable01"=dword:00da3700
"ColorTable02"=dword:000ea113
"ColorTable03"=dword:00dd963a
"ColorTable04"=dword:001f0fc5
"ColorTable05"=dword:00981788
"ColorTable06"=dword:00009cc1
"ColorTable07"=dword:00cccccc
"ColorTable08"=dword:00767676
"ColorTable09"=dword:00ff783b
"ColorTable10"=dword:000cc616
"ColorTable11"=dword:00d6d661
"ColorTable12"=dword:005648e7
"ColorTable13"=dword:009e00b4
"ColorTable14"=dword:00a5f1f9
"ColorTable15"=dword:00f2f2f2
"CtrlKeyShortcutsDisabled"=dword:00000000
"CursorColor"=dword:ffffffff
"CursorSize"=dword:00000019
"DefaultBackground"=dword:ffffffff
"DefaultForeground"=dword:ffffffff
"EnableColorSelection"=dword:00000000
"ExtendedEditKey"=dword:00000001
"ExtendedEditKeyCustom"=dword:00000000
"FaceName"="Consolas"
"FilterOnPaste"=dword:00000001
"FontFamily"=dword:00000036
"FontSize"=dword:00140000
"FontWeight"=dword:00000000
"ForceV2"=dword:00000000
"FullScreen"=dword:00000000
"HistoryBufferSize"=dword:00000032
"HistoryNoDup"=dword:00000000
"InsertMode"=dword:00000001
"LineSelection"=dword:00000001
"LineWrap"=dword:00000001
"LoadConIme"=dword:00000001
"NumberOfHistoryBuffers"=dword:00000004
"PopupColors"=dword:000000f5
"QuickEdit"=dword:00000001
"ScreenBufferSize"=dword:23290078
"ScreenColors"=dword:00000007
"ScrollScale"=dword:00000001
"TerminalScrolling"=dword:00000000
"TrimLeadingZeros"=dword:00000000
"WindowAlpha"=dword:000000ff
"WindowSize"=dword:001e0078
"WordDelimiters"=dword:00000000

[HKEY_LOCAL_MACHINE\Default\Console\%SystemRoot%_System32_cmd.exe]
"FaceName"="Consolas"
"FilterOnPaste"=dword:00000000
"FontSize"=dword:00100000
"FontWeight"=dword:00000190
"LineSelection"=dword:00000000
"LineWrap"=dword:00000000
"WindowAlpha"=dword:00000000
"WindowPosition"=dword:00000000
"WindowSize"=dword:00110054

[HKEY_LOCAL_MACHINE\Default\Console\%SystemRoot%_System32_WindowsPowerShell_v1.0_powershell.exe]
"ColorTable05"=dword:00562401
"ColorTable06"=dword:00f0edee
"FaceName"="Consolas"
"FilterOnPaste"=dword:00000000
"FontFamily"=dword:00000036
"FontSize"=dword:00140000
"FontWeight"=dword:00000190
"LineSelection"=dword:00000000
"LineWrap"=dword:00000000
"PopupColors"=dword:000000f3
"QuickEdit"=dword:00000001
"ScreenBufferSize"=dword:03e8012c
"ScreenColors"=dword:00000056
"WindowAlpha"=dword:00000000
"WindowSize"=dword:0020006c

[HKEY_LOCAL_MACHINE\Default\Console\%SystemRoot%_SysWOW64_WindowsPowerShell_v1.0_powershell.exe]
"ColorTable05"=dword:00562401
"ColorTable06"=dword:00f0edee
"FaceName"="Consolas"
"FilterOnPaste"=dword:00000000
"FontFamily"=dword:00000036
"FontSize"=dword:00140000
"FontWeight"=dword:00000190
"LineSelection"=dword:00000000
"LineWrap"=dword:00000000
"PopupColors"=dword:000000f3
"QuickEdit"=dword:00000001
"ScreenBufferSize"=dword:03e8012c
"ScreenColors"=dword:00000056
"WindowAlpha"=dword:00000000
"WindowSize"=dword:0020006c
'@
    #endregion
    #=================================================
    #region InfEnvironment
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
    #endregion
    #=================================================
    # Start Main
    $BuildDateTime = $((Get-Date).ToString('yyMMdd-HHmmss'))
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Starting $($MyInvocation.MyCommand.Name)"
    Block-WinPE
    Block-StandardUser
    Block-WindowsVersionNe10
    Block-PowerShellVersionLt5
    Block-NoCurl
    #=================================================
    #region UpdateUSB
    if ($UpdateUSB.IsPresent) {
        $UpdateUSB = $true
    }
    else {
        $UpdateUSB = $false
    }
    if ($AdkSkipOCs.IsPresent) {
        $AdkSkipOCs = $true
    }
    else {
        $AdkSkipOCs = $false
    }
    #endregion
    #=================================================
    #region Set TLS Defaults
    $PSDefaultParameterValues['Invoke-WebRequest:UseBasicParsing'] = $true
    if ($PSversionTable.PSEdition -ne 'Core') {
        $currentProgressPref = $ProgressPreference
        $ProgressPreference = 'SilentlyContinue'
    }

    if (-not $IsLinux -and -not $IsMacOs) {
        $regproxy = Get-ItemProperty -Path 'Registry::HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings'
        $proxy = $regproxy.ProxyServer

        if ($proxy -and -not ([System.Net.Webrequest]::DefaultWebProxy).Address -and $regproxy.ProxyEnable) {
            [System.Net.Webrequest]::DefaultWebProxy = New-object System.Net.WebProxy $proxy
            [System.Net.Webrequest]::DefaultWebProxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
        }
    }

    $currentVersionTls = [Net.ServicePointManager]::SecurityProtocol
    $currentSupportableTls = [Math]::Max($currentVersionTls.value__, [Net.SecurityProtocolType]::Tls.value__)
    $availableTls = [enum]::GetValues('Net.SecurityProtocolType') | Where-Object { $_ -gt $currentSupportableTls }
    $availableTls | ForEach-Object {
        [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor $_
    }
    #endregion
    #=================================================
    #region Test-IsWindowsAdkInstalled
    $IsWindowsAdkInstalled = Test-IsWindowsAdkInstalled -WarningAction SilentlyContinue
    $WindowsAdkInstallVersion = Get-WindowsAdkInstallVersion -WarningAction SilentlyContinue
    $WindowsAdkInstallPath = Get-WindowsAdkInstallPath -WarningAction SilentlyContinue
    
    if ($IsWindowsAdkInstalled) {
        if ($WindowsAdkInstallVersion) {
            Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Windows ADK install version is $WindowsAdkInstallVersion"
        }
        if ($WindowsAdkInstallPath) {
            Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Windows ADK install path is $WindowsAdkInstallPath"
        }
    }
    else {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Windows ADK is not installed."
    }
    #endregion
    #=================================================
    #region Get and Update the ADK Cache
    $OSDWorkspaceCachePath = Get-OSDWorkspaceCachePath -WarningAction SilentlyContinue
    $WindowsAdkCachePath = Get-OSDWorkspaceCacheAdkPath -WarningAction SilentlyContinue
    #endregion
    #=================================================
    #region Get the WindowsAdkCacheOptions
    $WindowsAdkCacheOptions = $null
    if (Test-Path $WindowsAdkCachePath) {
        $WindowsAdkCacheOptions = Get-ChildItem -Path "$WindowsAdkCachePath\*" -Directory -ErrorAction SilentlyContinue | Sort-Object -Property Name
    }
    #endregion
    #=================================================
    #region If ADK is installed then we need to update the cache
    if ($IsWindowsAdkInstalled) {
        $WindowsAdkRootPath = Join-Path $WindowsAdkCachePath $WindowsAdkInstallVersion
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Windows ADK cache content is $WindowsAdkRootPath"
        $null = robocopy "$WindowsAdkInstallPath" "$WindowsAdkRootPath" *.* /e /z /ndl /nfl /np /r:0 /w:0 /xj /njh /njs /mt:128
    }
    else {
        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Cannot update the ADK cache because the ADK is not installed"
        $AdkSelect = $true
        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] AdkSelect: $AdkSelect"
    }
    #endregion
    #=================================================
    #region ADK is not installed and not present in the cache
    if (($IsWindowsAdkInstalled -eq $false) -and (-not $WindowsAdkCacheOptions)) {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Windows ADK is not installed"
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] ADK cache does not contain an offline Windows ADK"
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Windows ADK will need to be installed before using this function"
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] https://learn.microsoft.com/en-us/windows-hardware/get-started/adk-install"
        return
    }
    #endregion
    #=================================================
    #region There is no usable ADK in the cache
    if ($WindowsAdkCacheOptions.Count -eq 0) {
        # Something is wrong, there should always be at least one ADK in the cache
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] ADK cache does not contain an offline Windows ADK"
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Windows ADK will need to be installed before using this function"
        return
    }
    #endregion
    #=================================================
    #region ADK is available by this point and we either have 1 or more to select from
    if ($WindowsAdkCacheOptions.Count -eq 1) {
        # Only one version of the ADK is present in the cache, so this must be used
        $WindowsAdkCacheSelected = $WindowsAdkCacheOptions.FullName
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] ADK cache contains 1 offline Windows ADK option"
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Using ADK cache at $WindowsAdkCacheSelected"

        # Can't select an ADK Version if there is only one
        $AdkSelect = $false
    }
    elseif ($WindowsAdkCacheOptions.Count -gt 1) {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] $($WindowsAdkCacheOptions.Count) Windows ADK options are available to select from the ADK cache"
        if ($AdkSelect) {
            Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Select a Windows ADK option and press OK (Cancel to Exit)"
            Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] To remove a Windows ADK option, delete one of the ADK cache directories in $WindowsAdkCachePath"
            $WindowsAdkCacheSelected = $WindowsAdkCacheOptions | Select-Object FullName | Sort-Object FullName -Descending | Out-GridView -Title 'Select a Windows ADK to use and press OK (Cancel to Exit)' -OutputMode Single
            if ($WindowsAdkCacheSelected) {
                $WindowsAdkRootPath = $WindowsAdkCacheSelected.FullName
            }
            else {
                Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Unable to set the ADK cache path"
                return
            }
        }
        else {
            Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Select a different Windows ADK with the -AdkSelect switch"
        }
    }
    else {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Something is wrong you should not be here"
        return
    }
    #endregion
    #=================================================
    #region Select BootImage
    <#
        We want to pick the BootImage first
        This will set the architecture automatically as the bootimage tells us and let that control what ADK architecture is going to be used.
        This way we don't have to prompt the user for the ADK architecture and can remove the parameter.
    #>
    if ($AdkWinPE) {
        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Using WinPE from Windows ADK"
        $WimSourceType = 'WinPE'
    }
    else {
        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Using WinRE from Select-OSDWorkspaceBootImage"
        $WimSourceType = 'WinRE'
        if ($Architecture) {
            $GetWindowsImage = Select-OSDWorkspaceBootImage -Architecture $Architecture
        }
        else {
            $GetWindowsImage = Select-OSDWorkspaceBootImage
        }

        if ($GetWindowsImage.Count -eq 0) {
            # There are no images to run
            return
        }
        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] GetWindowsImage = $GetWindowsImage"
        $Architecture = $GetWindowsImage.Architecture
        $BootImageCorePath = $GetWindowsImage.Path + '\core'
        $BootImageOSFilesPath = $GetWindowsImage.Path + '\core\os-files'

        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Using BootImage at $($GetWindowsImage.ImagePath)"
    }
    #endregion
    #=================================================
    #region Get ADK Paths
    if ($Architecture -eq 'amd64') {
        $WindowsAdkPaths = Get-WindowsAdkPaths -Architecture amd64 -AdkRoot $WindowsAdkRootPath -WarningAction SilentlyContinue
    }
    elseif ($Architecture -eq 'arm64') {
        $WindowsAdkPaths = Get-WindowsAdkPaths -Architecture arm64 -AdkRoot $WindowsAdkRootPath -WarningAction SilentlyContinue
    }
    else {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Unknown architecture $Architecture"
        return
    }
    if (-not $WindowsAdkPaths) {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Something is wrong you should not be here"
        return
    }
    if ($WimSourceType -eq 'WinPE') {
        $GetWindowsImage = Get-WindowsImage -ImagePath $($WindowsAdkPaths.WimSourcePath) -Index 1
        $BootImageWimPath = $GetWindowsImage.ImagePath
        $BootMediaName = "$($BuildDateTime) $($Architecture)"
        $BootMediaIsoLabel = "$($BuildDateTime)PE"
    }
    elseif ($WimSourceType -eq 'WinRE') {
        $BootImageWimPath = $GetWindowsImage.ImagePath
        $BootImageRootPath = $GetWindowsImage.Path
        $BootMediaName = "$($BuildDateTime) $($Architecture)"
        $BootMediaIsoLabel = "$($BuildDateTime)RE"
    }

    # Append the Name to the BootMediaName
    if ($Name) {
        $BootMediaName = "$BootMediaName $Name"
    }

    $WindowsAdkPaths.WimSourcePath = $BootImageWimPath
    
    $BootMediaIsoName = 'BootMedia.iso'
    $BootMediaIsoNameEX = 'BootMediaEX.iso'
    $BootMediaRootPath = Join-Path $(Get-OSDWorkspaceBootMediaPath) $BootMediaName
    $BootMediaCorePath = "$BootMediaRootPath\core"
    $BootMediaTempPath = "$BootMediaRootPath\temp"
    #endregion
    #=================================================
    #region Select-OSDWorkspaceBootMediaProfile
    $MyBootMediaProfile = $null
    $MyBootMediaProfile = Select-OSDWorkspaceLibraryBootMediaProfile
    #endregion
    #=================================================
    #region Select-OSDWorkspaceLibraryBootDriver
    $BootDriver = $null
    if (-not $MyBootMediaProfile) {
        $OSDWorkspaceBootDriver = Select-OSDWorkspaceLibraryBootDriver -Architecture $Architecture

        if ($OSDWorkspaceBootDriver) {
            $BootDriver = ($OSDWorkspaceBootDriver | Select-Object -ExpandProperty FullName)
        }
    }
    #endregion
    #=================================================
    #region Select-OSDWorkspaceLibraryBootFile
    $BootImageFile = $null
    $BootMediaFile = $null
    <#
    if (-not $MyBootMediaProfile) {
        $OSDWorkspaceBootFile = Select-OSDWorkspaceLibraryBootFile

        if ($OSDWorkspaceBootFile | Where-Object { $_.Phase -eq 'BootImage-File' }) {
            $BootImageFile = ($OSDWorkspaceBootFile | Where-Object { $_.Phase -eq 'BootImage-File' } | Select-Object -ExpandProperty FullName)
        }
        if ($OSDWorkspaceBootFile | Where-Object { $_.Phase -eq 'BootMedia-File' }) {
            $BootMediaFile = ($OSDWorkspaceBootFile | Where-Object { $_.Phase -eq 'BootMedia-File' } | Select-Object -ExpandProperty FullName)
        }
    }
    #>
    #endregion
    #=================================================
    #region Select-OSDWorkspaceLibraryBootScript
    $BootImageScript = $null
    $BootMediaScript = $null
    if (-not $MyBootMediaProfile) {
        $OSDWorkspaceBootScript = @()
        $OSDWorkspaceBootScript = Select-OSDWorkspaceLibraryBootScript

        if ($OSDWorkspaceBootScript | Where-Object { $_.Phase -eq 'BootImage-Script' }) {
            $BootImageScript = ($OSDWorkspaceBootScript | Where-Object { $_.Phase -eq 'BootImage-Script' } | Select-Object -ExpandProperty FullName)
        }
        if ($OSDWorkspaceBootScript | Where-Object { $_.Phase -eq 'BootMedia-Script' }) {
            $BootMediaScript = ($OSDWorkspaceBootScript | Where-Object { $_.Phase -eq 'BootMedia-Script' } | Select-Object -ExpandProperty FullName)
        }
    }
    #endregion
    #=================================================
    #region Select-OSDWorkspaceLibraryBootStartnet
    <#
    if (-not $MyBootMediaProfile) {
        $OSDWorkspaceBootStartnet = Select-OSDWorkspaceLibraryBootStartnet

        if ($OSDWorkspaceBootStartnet) {
            $BootStartnet = ($OSDWorkspaceBootStartnet | Select-Object -ExpandProperty FullName)
        }
    }
    #>
    #endregion
    #=================================================
    #region MyBootMediaProfile
    if ($MyBootMediaProfile) {
        $global:BootMediaProfile = $null
        $global:BootMediaProfile = Get-Content $MyBootMediaProfile.FullName -Raw | ConvertFrom-Json
        
        $BootDriver = $global:BootMediaProfile.BootDriver
        $BootImageFile = $global:BootMediaProfile.BootImageFile
        $BootImageScript = $global:BootMediaProfile.BootImageScript
        $BootMediaFile = $global:BootMediaProfile.BootMediaFile
        $BootMediaScript = $global:BootMediaProfile.BootMediaScript
        $BootStartnet = $global:BootMediaProfile.BootStartnet
        [System.String[]]$Languages = $global:BootMediaProfile.Languages
        $SetAllIntl = $global:BootMediaProfile.SetAllIntl
        $SetInputLocale = $global:BootMediaProfile.SetInputLocale
        $TimeZone = $global:BootMediaProfile.TimeZone

        $MyBootMediaProfilePath = $MyBootMediaProfile.FullName
    }
    else {
        $global:BootMediaProfile = $null
        $global:BootMediaProfile = [ordered]@{
            BootDriver      = $BootDriver
            BootImageFile   = $BootImageFile
            BootImageScript = $BootImageScript
            BootMediaFile   = $BootMediaFile
            BootMediaScript = $BootMediaScript
            BootStartnet    = $BootStartnet
            Languages       = [System.String[]]$Languages
            SetAllIntl      = [System.String]$SetAllIntl
            SetInputLocale  = [System.String]$SetInputLocale
            TimeZone        = [System.String]$TimeZone
        }

        $BootMediaProfilePath = Join-Path $(Get-OSDWorkspaceLibraryPath) 'BootMedia-Profile'

        if (-not (Test-Path $BootMediaProfilePath)) {
            $null = New-Item -Path $BootMediaProfilePath -ItemType Directory -Force
        }

        $MyBootMediaProfilePath = "$BootMediaProfilePath\$Name.json"

        Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Exporting BootMedia Profile to $MyBootMediaProfilePath"
        $global:BootMediaProfile | ConvertTo-Json | Out-File $MyBootMediaProfilePath -Encoding utf8 -Force
    }
    #endregion
    #=================================================
    #region BootMediaProfile
    $global:BootMedia = $null
    $global:BootMedia = [ordered]@{
        AddAzCopy          = $false
        AddMicrosoftDaRT   = $false
        AddPwsh            = $false
        AddWirelessConnect = $false
        AddZip             = $false
        AdkCachePath       = $WindowsAdkCachePath
        AdkInstallPath     = $WindowsAdkInstallPath
        AdkInstallVersion  = $WindowsAdkInstallVersion
        AdkRootPath        = $WindowsAdkRootPath
        AdkSelect          = $AdkSelect
        AdkSkipOCs         = $AdkSkipOCs
        AdkWinPE           = $AdkWinPE
        Architecture       = [System.String]$Architecture
        BootDriver         = $BootDriver
        BootImageFile      = $BootImageFile
        BootImageRootPath  = $BootImageRootPath
        BootImageScript    = $BootImageScript
        BootImageWimPath   = $BootImageWimPath
        BootMediaFile      = $BootMediaFile
        BootMediaIsoLabel  = $BootMediaIsoLabel
        BootMediaIsoName   = $BootMediaIsoName
        BootMediaIsoNameEX = $BootMediaIsoNameEX
        BootMediaName      = $BootMediaName
        BootMediaProfile   = $MyBootMediaProfilePath
        BootMediaRootPath  = $BootMediaRootPath
        BootMediaScript    = $BootMediaScript
        BootStartnet       = $BootStartnet
        Languages          = [System.String[]]$Languages
        MediaPath          = Join-Path $BootMediaRootPath 'Media'
        MediaPathEX        = $null
        MountPath          = $MountPath
        Name               = [System.String]$Name
        OSDCachePath       = $OSDWorkspaceCachePath
        PEVersion          = $GetWindowsImage.Version
        SetAllIntl         = [System.String]$SetAllIntl
        SetInputLocale     = [System.String]$SetInputLocale
        StartnetContent    = $StartnetContent
        TimeZone           = [System.String]$TimeZone
        UpdateUSB          = $UpdateUSB
        WimSourceType      = $WimSourceType
        WinpeshlContent    = $WinpeshlContent
    }
    #endregion
    #=================================================
    #   Point of No Return
    #=================================================
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Use the `$global:BootMedia variable in your PowerShell Scripts for this BootMedia configuration"
    Write-Output $global:BootMedia
    Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Press CTRL+C to cancel"
    Pause
    $BuildStartTime = Get-Date
    #=================================================
    #region Start Main
    $WinPEBootMediaLogs = "$BootMediaCorePath\logs"
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] BootMediaCorePath: $BootMediaCorePath"

    if (-not (Test-Path $BootMediaRootPath)) {
        $null = New-Item -Path $BootMediaRootPath -ItemType Directory -Force
    }
    if (-not (Test-Path $WinPEBootMediaLogs)) {
        $null = New-Item -Path $WinPEBootMediaLogs -ItemType Directory -Force | Out-Null
    }

    $Transcript = "$((Get-Date).ToString('yyMMdd-HHmmss'))-New-OSDWorkspaceBootMedia.log"
    Start-Transcript -Path (Join-Path $WinPEBootMediaLogs $Transcript) -ErrorAction SilentlyContinue
    #endregion
    #=================================================
    #region Copy Core
    if ($BootImageCorePath) {
        if (Test-Path $BootImageCorePath) {
            Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Hydrate [$BootMediaCorePath]"
            $null = robocopy "$BootImageCorePath" "$BootMediaCorePath" *.* /mir /b /nfl /ndl /np /r:0 /w:0 /xj /njs /mt:128
        }
    }
    #endregion
    #=================================================
    #region Build Media
    $MediaPath = $global:BootMedia.MediaPath
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] `$MediaPath = $MediaPath"
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Hydrate [$MediaPath]"
    $null = robocopy "$($WindowsAdkPaths.PathWinPEMedia)" "$MediaPath" *.* /mir /b /ndl /np /r:0 /w:0 /xj /njs /mt:128 /LOG+:$WinPEBootMediaLogs\Robocopy.log

    Copy-Item -Path "$BootMediaCorePath\os-boot\DVD\EFI\en-US\efisys.bin" -Destination "$MediaPath\EFI\Microsoft\Boot\efisys.bin" -Force -ErrorAction SilentlyContinue
    Copy-Item -Path "$BootMediaCorePath\os-boot\DVD\EFI\en-US\efisys_noprompt.bin" -Destination "$MediaPath\EFI\Microsoft\Boot\efisys_noprompt.bin" -Force -ErrorAction SilentlyContinue

    $Fonts = @('malgunn_boot.ttf', 'meiryon_boot.ttf', 'msjhn_boot.ttf', 'msyhn_boot.ttf', 'segoen_slboot.ttf')
    foreach ($Font in $Fonts) {
        if (Test-Path "$BootMediaCorePath\os-boot\Fonts\$Font") {
            Copy-Item -Path "$BootMediaCorePath\os-boot\Fonts\$Font" -Destination "$MediaPath\EFI\Microsoft\Boot\Fonts\$Font" -Force -ErrorAction SilentlyContinue
        }
    }
    #endregion
    #=================================================
    #region Build MediaEX
    if (Test-Path "$BootMediaCorePath\os-boot\EFI_EX") {
        $global:BootMedia.MediaPathEX = Join-Path $BootMediaRootPath 'MediaEX'
        $MediaPathEX = $global:BootMedia.MediaPathEX
        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] `$MediaPathEX = $MediaPathEX"
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Hydrate $MediaPathEX"
        $null = robocopy "$($WindowsAdkPaths.PathWinPEMedia)" "$MediaPathEX" *.* /mir /b /ndl /np /r:0 /w:0 /xj /njs /mt:128 /LOG+:$WinPEBootMediaLogs\Robocopy.log

        Write-Host -ForegroundColor Yellow "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Mitigate [$MediaPathEX] CVE-2022-21894 Secure Boot Security Feature Bypass Vulnerability aka BlackLotus"
        Remove-Item -Path "$MediaPathEX\EFI\Microsoft\Boot\Fonts" -Recurse -Force
        if (-not (Test-Path "$MediaPathEX\EFI\Microsoft\Boot\Fonts")) {
            New-Item -Path "$MediaPathEX\EFI\Microsoft\Boot\Fonts" -ItemType Directory -Force | Out-Null
        }

        Copy-Item -Path "$BootMediaCorePath\os-boot\EFI_EX\bootmgr_ex.efi" -Destination "$MediaPathEX\bootmgr.efi" -Force -ErrorAction SilentlyContinue
        Copy-Item -Path "$BootMediaCorePath\os-boot\EFI_EX\bootmgfw_ex.efi" -Destination "$MediaPathEX\EFI\Boot\bootx64.efi" -Force -ErrorAction SilentlyContinue
        Copy-Item -Path "$BootMediaCorePath\os-boot\Fonts_EX\chs_boot_EX.ttf" -Destination "$MediaPathEX\EFI\Microsoft\Boot\Fonts\chs_boot.ttf" -Force -ErrorAction SilentlyContinue
        Copy-Item -Path "$BootMediaCorePath\os-boot\Fonts_EX\cht_boot_EX.ttf" -Destination "$MediaPathEX\EFI\Microsoft\Boot\Fonts\cht_boot.ttf" -Force -ErrorAction SilentlyContinue
        Copy-Item -Path "$BootMediaCorePath\os-boot\Fonts_EX\jpn_boot_EX.ttf" -Destination "$MediaPathEX\EFI\Microsoft\Boot\Fonts\jpn_boot.ttf" -Force -ErrorAction SilentlyContinue
        Copy-Item -Path "$BootMediaCorePath\os-boot\Fonts_EX\kor_boot_EX.ttf" -Destination "$MediaPathEX\EFI\Microsoft\Boot\Fonts\kor_boot.ttf" -Force -ErrorAction SilentlyContinue
        Copy-Item -Path "$BootMediaCorePath\os-boot\Fonts_EX\malgun_boot_EX.ttf" -Destination "$MediaPathEX\EFI\Microsoft\Boot\Fonts\malgun_boot.ttf" -Force -ErrorAction SilentlyContinue
        Copy-Item -Path "$BootMediaCorePath\os-boot\Fonts_EX\malgunn_boot_EX.ttf" -Destination "$MediaPathEX\EFI\Microsoft\Boot\Fonts\malgunn_boot.ttf" -Force -ErrorAction SilentlyContinue
        Copy-Item -Path "$BootMediaCorePath\os-boot\Fonts_EX\meiryo_boot_EX.ttf" -Destination "$MediaPathEX\EFI\Microsoft\Boot\Fonts\meiryo_boot.ttf" -Force -ErrorAction SilentlyContinue
        Copy-Item -Path "$BootMediaCorePath\os-boot\Fonts_EX\meiryon_boot_EX.ttf" -Destination "$MediaPathEX\EFI\Microsoft\Boot\Fonts\meiryon_boot.ttf" -Force -ErrorAction SilentlyContinue
        Copy-Item -Path "$BootMediaCorePath\os-boot\Fonts_EX\msjh_boot_EX.ttf" -Destination "$MediaPathEX\EFI\Microsoft\Boot\Fonts\msjh_boot.ttf" -Force -ErrorAction SilentlyContinue
        Copy-Item -Path "$BootMediaCorePath\os-boot\Fonts_EX\msjhn_boot_EX.ttf" -Destination "$MediaPathEX\EFI\Microsoft\Boot\Fonts\msjhn_boot.ttf" -Force -ErrorAction SilentlyContinue
        Copy-Item -Path "$BootMediaCorePath\os-boot\Fonts_EX\msyh_boot_EX.ttf" -Destination "$MediaPathEX\EFI\Microsoft\Boot\Fonts\msyh_boot.ttf" -Force -ErrorAction SilentlyContinue
        Copy-Item -Path "$BootMediaCorePath\os-boot\Fonts_EX\msyhn_boot_EX.ttf" -Destination "$MediaPathEX\EFI\Microsoft\Boot\Fonts\msyhn_boot.ttf" -Force -ErrorAction SilentlyContinue
        Copy-Item -Path "$BootMediaCorePath\os-boot\Fonts_EX\segmono_boot_EX.ttf" -Destination "$MediaPathEX\EFI\Microsoft\Boot\Fonts\segmono_boot.ttf" -Force -ErrorAction SilentlyContinue
        Copy-Item -Path "$BootMediaCorePath\os-boot\Fonts_EX\segoe_slboot_EX.ttf" -Destination "$MediaPathEX\EFI\Microsoft\Boot\Fonts\segoe_slboot.ttf" -Force -ErrorAction SilentlyContinue
        Copy-Item -Path "$BootMediaCorePath\os-boot\Fonts_EX\segoen_slboot_EX.ttf" -Destination "$MediaPathEX\EFI\Microsoft\Boot\Fonts\segoen_slboot.ttf" -Force -ErrorAction SilentlyContinue
        Copy-Item -Path "$BootMediaCorePath\os-boot\Fonts_EX\wgl4_boot_EX.ttf" -Destination "$MediaPathEX\EFI\Microsoft\Boot\Fonts\wgl4_boot.ttf" -Force -ErrorAction SilentlyContinue
        Copy-Item -Path "$BootMediaCorePath\os-boot\DVD_EX\EFI\en-US\efisys_EX.bin" -Destination "$MediaPathEX\EFI\Microsoft\Boot\efisys.bin" -Force -ErrorAction SilentlyContinue
        Copy-Item -Path "$BootMediaCorePath\os-boot\DVD_EX\EFI\en-US\efisys_noprompt_EX.bin" -Destination "$MediaPathEX\EFI\Microsoft\Boot\efisys_noprompt.bin" -Force -ErrorAction SilentlyContinue
    }
    else {
        $MediaPathEX = $null
    }
    #endregion
    #=================================================
    #region Build Sources
    $buildMediaSourcesPath = Join-Path $MediaPath 'sources'
    if (-not (Test-Path "$buildMediaSourcesPath")) {
        New-Item -Path "$buildMediaSourcesPath" -ItemType Directory -Force -ErrorAction Stop | Out-Null
    }
    $buildMediaSourcesBootwimPath = Join-Path $buildMediaSourcesPath 'boot.wim'
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Copy [$buildMediaSourcesBootwimPath]"
    Copy-Item -Path $WindowsAdkPaths.WimSourcePath -Destination $buildMediaSourcesBootwimPath -Force -ErrorAction Stop | Out-Null

    if (!(Test-Path $buildMediaSourcesBootwimPath)) {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Unknown issue copying $buildMediaSourcesBootwimPath"
        Stop-Transcript
        Break
    }
    attrib -s -h -r $buildMediaSourcesPath
    attrib -s -h -r $buildMediaSourcesBootwimPath

    if ($MediaPathEX) {
        $buildMediaSourcesPathEX = Join-Path $MediaPathEX 'sources'
        if (-not (Test-Path "$buildMediaSourcesPathEX")) {
            New-Item -Path "$buildMediaSourcesPathEX" -ItemType Directory -Force -ErrorAction Stop | Out-Null
        }
        attrib -s -h -r $buildMediaSourcesPathEX
    }
    #endregion
    #=================================================
    #region wgl4_boot.ttf
    #This is used to resolve issues with WinPE Resolutions in 2004/20H2
    <#
    if ((Get-RegCurrentVersion).CurrentBuild -lt 20000) {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Replacing Boot Media font wgl4_boot.ttf"
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Replacing this file resolves an issue where WinPE does not boot to the proper display resolution"
    
        $NotUsedUri = 'https://github.com/OSDeploy/OSDCloud/raw/main/Media/boot/fonts/wgl4_boot.ttf'
        if (Test-WebConnection -Uri $NotUsedUri) {
            Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Source: $NotUsedUri"
            Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Destination: $MediaPath\boot\fonts\wgl4_boot.ttf"
            # OSDTools
            Save-WebFile -SourceUrl $NotUsedUri -DestinationDirectory "$MediaPath\boot\fonts" -Overwrite | Out-Null
        }
    
        $NotUsedUri = 'https://github.com/OSDeploy/OSDCloud/raw/main/Media/efi/microsoft/boot/fonts/wgl4_boot.ttf'
        if (Test-WebConnection -Uri $NotUsedUri) {
            Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Source: $NotUsedUri"
            Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Destination: $MediaPath\efi\microsoft\boot\fonts\wgl4_boot.ttf"
            # OSDTools
            Save-WebFile -SourceUrl $NotUsedUri -DestinationDirectory "$MediaPath\efi\microsoft\boot\fonts" -Overwrite | Out-Null
        }
    }
    #>
    #endregion
    #=================================================
    #region BootImage Mount
    $WindowsImage = Mount-MyWindowsImage $buildMediaSourcesBootwimPath
    $MountPath = $WindowsImage.Path
    $global:BootMedia.MountPath = $MountPath
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] [$buildMediaSourcesBootwimPath] --> [$MountPath]"
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] MountPath: $MountPath"
    #endregion
    #=================================================
    #region Export Get-WindowsPackage
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Export [$BootMediaCorePath\winpe-WindowsPackage.xml]"
    $WindowsPackage = $WindowsImage | Get-WindowsPackage
    if ($WindowsPackage) {
        $WindowsPackage | Select-Object * | Export-Clixml -Path "$BootMediaCorePath\winpe-WindowsPackage.xml" -Force
    }
    #endregion
    #=================================================
    #region BootImage Registry Information
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Export WinPE HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
    $RegKeyCurrentVersion = Get-RegCurrentVersion -Path $MountPath
    Write-Output $RegKeyCurrentVersion
    #endregion
    #=================================================
    #region BootImage Registry Information
    if ($BootImageOSFilesPath) {
        if (Test-Path $BootImageOSFilesPath) {
            Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Adding OS Files from $BootImageOSFilesPath"
            robocopy "$BootImageOSFilesPath" "$MountPath" *.* /s /b /ndl /nfl /np /ts /tee /r:0 /w:0 /xf bcp47*.dll /xx /xj /njs /mt:128
        }
    }
    #endregion
    #=================================================
    if ($AdkSkipOCs -eq $false) {
        #region Apply ADK Packages
        $WinPEOCs = $WindowsAdkPaths.WinPEOCs

        if ($Architecture -eq 'amd64') {
            $WinpeOCPackages = @(
                'WMI'
                'NetFx'
                'Scripting'
                'HTA'
                'PowerShell'
                'SecureStartup'
                'DismCmdlets'
                'Dot3Svc'
                'EnhancedStorage'
                'FMAPI'
                'GamingPeripherals'
                'HSP-Driver'
                'PPPoE'
                'PlatformId'
                'PmemCmdlets'
                'RNDIS'
                'SecureBootCmdlets'
                'StorageWMI'
                'WDS-Tools'
            )
        }
        if ($Architecture -eq 'arm64') {
            $WinpeOCPackages = @(
                'WMI'
                'NetFx'
                'Scripting'
                'HTA'
                'PowerShell'
                'SecureStartup'
                'DismCmdlets'
                'Dot3Svc'
                'EnhancedStorage'
                'FMAPI'
                'GamingPeripherals'
                'PPPoE'
                'PlatformId'
                'PmemCmdlets'
                'RNDIS'
                'SecureBootCmdlets'
                'StorageWMI'
                'WDS-Tools'
                'x64-Support'
                'MDAC'
            )
        }
        #endregion
        #=================================================
        #region OSDeploy Install Default en-us Language
        Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Adding ADK Packages for Language en-us"
        $Lang = 'en-us'

        foreach ($Package in $WinpeOCPackages) {
            $PackageFile = "$WinPEOCs\WinPE-$Package.cab"

            if (Test-Path $PackageFile) {

                <#
            if ($Package -match 'GamingPeripherals') {
                if ($GetWindowsImage.Version -eq '10.0.26100.2876') {
                    Write-Host -ForegroundColor DarkGray "$PackageFile (Skipping for WinPE 10.0.26100.2876 due to issues)"
                    Continue
                }
            }
            #>

                Write-Host -ForegroundColor Gray "$PackageFile"
                $PackageName = "Add-WindowsPackage-WinPE-$Package"
                $CurrentLog = "$WinPEBootMediaLogs\$((Get-Date).ToString('yyMMdd-HHmmss'))-$PackageName.log"

                try {
                    # Dism
                    #Start-Process Dism -ArgumentList "/Image:""$MountPath""", '/Add-Package', "/PackagePath:""$PackageFile""", '/IgnoreCheck' -NoNewWindow -Wait

                    # PowerShell
                    $null = $WindowsImage | Add-WindowsPackage -PackagePath $PackageFile -IgnoreCheck -LogPath "$CurrentLog" -ErrorAction Stop
                }
                catch {
                    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] If this package is not essential, it is recommended to try again without this package as the Windows Image may now be unserviceable"
                    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Log: $CurrentLog"
                    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] ErrorCode: $($_.Exception.ErrorCode)"
                    if ($_.Exception.ErrorCode -eq '-2147024893') {
                        #Write-Warning '0x80070003 ERROR_PATH_NOT_FOUND The system cannot find the path specified.'
                        # Start-Sleep -Seconds 5
                    }
                    if ($_.Exception.ErrorCode -eq '-2148468766') {
                        #Write-Warning '0x800f081e CBS_E_NOT_APPLICABLE suggests that the package is not compatible with the Windows Image that is being serviced'
                        Write-Warning 'Make sure the Windows ADK version you are using supports the WinPE version you are trying to service'
                        # Start-Sleep -Seconds 5
                    }
                    if ($_.Exception.ErrorCode -eq '-2146498512') {
                        Write-Error '0x800f0830 CBS_E_IMAGE_UNSERVICEABLE The specified image is no longer serviceable and may be corrupted. Discard the modified image and start again.'
                        #Write-Warning 'If this package is not essential, it is recommended to try again without this package as the Windows Image is now unserviceable'
                        # Start-Sleep -Seconds 5
                    }
                    Write-Error $_.Exception.Message
                    Start-Sleep -Seconds 10
                }
            }
            else {
                Write-Host -ForegroundColor DarkGray "$PackageFile (not present)"
            }
        }

        # Bail if the PowerShell package did not install
        if (-not ($WindowsImage | Get-WindowsPackage | Where-Object { $_.PackageName -match 'PowerShell' })) {
            #if (-not (Get-WindowsPackage -Path $MountPath | Where-Object {$_.PackageName -match "PowerShell"})) {
            Write-Warning 'Required ADK Packages did not install properly'
            Write-Warning 'Make sure the Windows ADK version you are using supports the WinRE version you are trying to service'
            Start-Sleep -Seconds 10
            #Write-Error -Message 'Required ADK Packages did not install properly'
            #Write-Error -Message 'Make sure the Windows ADK version you are using supports the WinRE version you are trying to service'
            #Write-Error -Message 'Dismounting Windows Image and Exiting'
            #$null = $WindowsImage | Dismount-WindowsImage -Discard
            #Stop-Transcript
            #Break
        }

        $PackageFile = "$WinPEOCs\$Lang\lp.cab"
        if (Test-Path $PackageFile) {
            Write-Host -ForegroundColor Gray "$PackageFile"
            $PackageName = "Add-WindowsPackage-WinPE-lp_$Lang"
            $CurrentLog = "$WinPEBootMediaLogs\$((Get-Date).ToString('yyMMdd-HHmmss'))-$PackageName.log"

            try {
                # Dism
                #Start-Process Dism -ArgumentList "/Image:""$MountPath""", '/Add-Package', "/PackagePath:""$PackageFile""", '/IgnoreCheck' -NoNewWindow -Wait

                # PowerShell
                $null = $WindowsImage | Add-WindowsPackage -PackagePath $PackageFile -IgnoreCheck -LogPath "$CurrentLog" -ErrorAction Stop
            }
            catch {
                Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] If this package is not essential, it is recommended to try again without this package as the Windows Image may now be unserviceable"
                Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Log: $CurrentLog"
                Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] ErrorCode: $($_.Exception.ErrorCode)"
                if ($_.Exception.ErrorCode -eq '-2147024893') {
                    #Write-Warning '0x80070003 ERROR_PATH_NOT_FOUND The system cannot find the path specified.'
                    # Start-Sleep -Seconds 5
                }
                if ($_.Exception.ErrorCode -eq '-2148468766') {
                    #Write-Warning '0x800f081e CBS_E_NOT_APPLICABLE suggests that the package is not compatible with the Windows Image that is being serviced'
                    Write-Warning 'Make sure the Windows ADK version you are using supports the WinPE version you are trying to service'
                    # Start-Sleep -Seconds 5
                }
                if ($_.Exception.ErrorCode -eq '-2146498512') {
                    Write-Error '0x800f0830 CBS_E_IMAGE_UNSERVICEABLE The specified image is no longer serviceable and may be corrupted. Discard the modified image and start again.'
                    #Write-Warning 'If this package is not essential, it is recommended to try again without this package as the Windows Image is now unserviceable'
                    Start-Sleep -Seconds 5
                }
                Write-Error $_.Exception.Message
                Start-Sleep -Seconds 10
            }
        }
        else {
            Write-Host -ForegroundColor DarkGray "$PackageFile (not present)"
        }

        foreach ($Package in $WinpeOCPackages) {
            $PackageFile = "$WinPEOCs\$Lang\WinPE-$Package`_$Lang.cab"

            if (Test-Path $PackageFile) {

                <#
            if ($Package -match 'GamingPeripherals') {
                if ($GetWindowsImage.Version -eq '10.0.26100.2876') {
                    Write-Host -ForegroundColor DarkGray "$PackageFile (Skipping for WinPE 10.0.26100.2876 due to issues)"
                    Continue
                }
            }
            #>

                Write-Host -ForegroundColor Gray "$PackageFile"
                $PackageName = "Add-WindowsPackage-WinPE-$Package`_$Lang"
                $CurrentLog = "$WinPEBootMediaLogs\$((Get-Date).ToString('yyMMdd-HHmmss'))-$PackageName.log"

                try {
                    # Dism
                    #Start-Process Dism -ArgumentList "/Image:""$MountPath""", '/Add-Package', "/PackagePath:""$PackageFile""", '/IgnoreCheck' -NoNewWindow -Wait

                    # PowerShell
                    $null = $WindowsImage | Add-WindowsPackage -PackagePath $PackageFile -IgnoreCheck -LogPath "$CurrentLog" -ErrorAction Stop
                }
                catch {
                    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] If this package is not essential, it is recommended to try again without this package as the Windows Image may now be unserviceable"
                    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Log: $CurrentLog"
                    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] ErrorCode: $($_.Exception.ErrorCode)"
                    if ($_.Exception.ErrorCode -eq '-2147024893') {
                        #Write-Warning '0x80070003 ERROR_PATH_NOT_FOUND The system cannot find the path specified.'
                        # Start-Sleep -Seconds 5
                    }
                    if ($_.Exception.ErrorCode -eq '-2148468766') {
                        #Write-Warning '0x800f081e CBS_E_NOT_APPLICABLE suggests that the package is not compatible with the Windows Image that is being serviced'
                        Write-Warning 'Make sure the Windows ADK version you are using supports the WinPE version you are trying to service'
                        # Start-Sleep -Seconds 5
                    }
                    if ($_.Exception.ErrorCode -eq '-2146498512') {
                        Write-Error '0x800f0830 CBS_E_IMAGE_UNSERVICEABLE The specified image is no longer serviceable and may be corrupted. Discard the modified image and start again.'
                        #Write-Warning 'If this package is not essential, it is recommended to try again without this package as the Windows Image is now unserviceable'
                        Start-Sleep -Seconds 5
                    }
                    Write-Error $_.Exception.Message
                    Start-Sleep -Seconds 10
                }
            }
            else {
                Write-Host -ForegroundColor DarkGray "$PackageFile (not present)"
            }
        }
        #endregion
        #=================================================
        #region OSDeploy Save-WindowsImage
        Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Saving Windows Image at $MountPath"
        $CurrentLog = "$WinPEBootMediaLogs\$((Get-Date).ToString('yyMMdd-HHmmss'))-Save-WindowsImage.log"
        $WindowsImage | Save-WindowsImage -LogPath $CurrentLog
        #Save-WindowsImage -Path $MountPath -LogPath $CurrentLog | Out-Null
        #endregion
        #=================================================
        #region OSDeploy Install Selected Language
        if ($Languages -contains '*') {
            $Languages = Get-ChildItem $WinPEOCs -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -ne 'en-us' } | Select-Object -ExpandProperty Name
        }

        foreach ($Lang in $Languages) {
            if ($Lang -eq 'en-us') { Continue }
            Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Adding $Lang ADK Packages"

            $PackageFile = "$WinPEOCs\$Lang\lp.cab"
            if (Test-Path $PackageFile) {
                Write-Host -ForegroundColor Gray "$PackageFile"
                $PackageName = "Add-WindowsPackage-WinPE-lp_$Lang"
                $CurrentLog = "$WinPEBootMediaLogs\$((Get-Date).ToString('yyMMdd-HHmmss'))-$PackageName.log"
    
                try {
                    # Dism
                    #Start-Process Dism -ArgumentList "/Image:""$MountPath""", '/Add-Package', "/PackagePath:""$PackageFile""", '/IgnoreCheck' -NoNewWindow -Wait

                    # PowerShell
                    $null = $WindowsImage | Add-WindowsPackage -PackagePath $PackageFile -IgnoreCheck -LogPath "$CurrentLog" -ErrorAction Stop
                }
                catch {
                    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] If this package is not essential, it is recommended to try again without this package as the Windows Image may now be unserviceable"
                    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Log: $CurrentLog"
                    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] ErrorCode: $($_.Exception.ErrorCode)"
                    if ($_.Exception.ErrorCode -eq '-2147024893') {
                        #Write-Warning '0x80070003 ERROR_PATH_NOT_FOUND The system cannot find the path specified.'
                        # Start-Sleep -Seconds 5
                    }
                    if ($_.Exception.ErrorCode -eq '-2148468766') {
                        #Write-Warning '0x800f081e CBS_E_NOT_APPLICABLE suggests that the package is not compatible with the Windows Image that is being serviced'
                        Write-Warning 'Make sure the Windows ADK version you are using supports the WinPE version you are trying to service'
                        # Start-Sleep -Seconds 5
                    }
                    if ($_.Exception.ErrorCode -eq '-2146498512') {
                        Write-Error '0x800f0830 CBS_E_IMAGE_UNSERVICEABLE The specified image is no longer serviceable and may be corrupted. Discard the modified image and start again.'
                        #Write-Warning 'If this package is not essential, it is recommended to try again without this package as the Windows Image is now unserviceable'
                        Start-Sleep -Seconds 5
                    }
                    Write-Error $_.Exception.Message
                    Start-Sleep -Seconds 10
                }
            }
            else {
                Write-Host -ForegroundColor DarkGray "$PackageFile (not present)"
            }

            foreach ($Package in $WinpeOCPackages) {
                $PackageFile = "$WinPEOCs\$Lang\WinPE-$Package`_$Lang.cab"
                if (Test-Path $PackageFile) {
                    Write-Host -ForegroundColor Gray "$PackageFile"
                    $PackageName = "Add-WindowsPackage-WinPE-$Package`_$Lang"
                    $CurrentLog = "$WinPEBootMediaLogs\$((Get-Date).ToString('yyMMdd-HHmmss'))-$PackageName.log"
                
                    try {
                        # Dism
                        #Start-Process Dism -ArgumentList "/Image:""$MountPath""", '/Add-Package', "/PackagePath:""$PackageFile""", '/IgnoreCheck' -NoNewWindow -Wait

                        # PowerShell
                        $null = $WindowsImage | Add-WindowsPackage -PackagePath $PackageFile -IgnoreCheck -LogPath "$CurrentLog" -ErrorAction Stop
                    }
                    catch {
                        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] If this package is not essential, it is recommended to try again without this package as the Windows Image may now be unserviceable"
                        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Log: $CurrentLog"
                        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] ErrorCode: $($_.Exception.ErrorCode)"
                        if ($_.Exception.ErrorCode -eq '-2147024893') {
                            #Write-Warning '0x80070003 ERROR_PATH_NOT_FOUND The system cannot find the path specified.'
                            # Start-Sleep -Seconds 5
                        }
                        if ($_.Exception.ErrorCode -eq '-2148468766') {
                            #Write-Warning '0x800f081e CBS_E_NOT_APPLICABLE suggests that the package is not compatible with the Windows Image that is being serviced'
                            Write-Warning 'Make sure the Windows ADK version you are using supports the WinPE version you are trying to service'
                            # Start-Sleep -Seconds 5
                        }
                        if ($_.Exception.ErrorCode -eq '-2146498512') {
                            Write-Error '0x800f0830 CBS_E_IMAGE_UNSERVICEABLE The specified image is no longer serviceable and may be corrupted. Discard the modified image and start again.'
                            #Write-Warning 'If this package is not essential, it is recommended to try again without this package as the Windows Image is now unserviceable'
                            Start-Sleep -Seconds 5
                        }
                        Write-Error $_.Exception.Message
                        Start-Sleep -Seconds 10
                    }
                }
                else {
                    Write-Host -ForegroundColor DarkGray "$PackageFile (not present)"
                }
            }

            # Generates a new Lang.ini file which is used to define the language packs inside the image
            if ( (Test-Path -Path "$MountPath\sources\lang.ini") ) {
                Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Updating lang.ini"
                $CurrentLog = "$WinPEBootMediaLogs\$((Get-Date).ToString('yyMMdd-HHmmss'))-Gen-LangINI.log"
                DISM /image:"$MountPath" /Gen-LangINI /distribution:"$MountPath" /LogPath:"$CurrentLog"
            }
        
            Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Save Windows Image"
            $CurrentLog = "$WinPEBootMediaLogs\$((Get-Date).ToString('yyMMdd-HHmmss'))-Save-WindowsImage.log"
            Save-WindowsImage -Path $MountPath -LogPath $CurrentLog | Out-Null
        }
        #endregion
    }
    #=================================================
    #region Apply DISM TimeZone
    Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Set-TimeZone to $TimeZone"
    Start-Process Dism -ArgumentList "/Image:""$MountPath""", "/Set-TimeZone:""$TimeZone""" -NoNewWindow -Wait
    #endregion
    #=================================================
    #region Apply DISM International Settings
    if ($SetAllIntl -or $SetInputLocale) {
        Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Get-Intl current configuration"
        $CurrentLog = "$WinPEBootMediaLogs\$((Get-Date).ToString('yyMMdd-HHmmss'))-Get-Intl.log"
        Dism /image:"$MountPath" /Get-Intl /LogPath:"$CurrentLog"
    }

    if ($SetAllIntl) {
        Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Set-AllIntl to $SetAllIntl"
        $CurrentLog = "$WinPEBootMediaLogs\$((Get-Date).ToString('yyMMdd-HHmmss'))-Set-AllIntl.log"
        Dism /image:"$MountPath" /Set-AllIntl:$SetAllIntl /LogPath:"$CurrentLog"
    }

    if ($SetInputLocale) {
        Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Set-InputLocale to $SetInputLocale"
        $CurrentLog = "$WinPEBootMediaLogs\$((Get-Date).ToString('yyMMdd-HHmmss'))-Set-InputLocale.log"
        Dism /image:"$MountPath" /Set-InputLocale:$SetInputLocale /LogPath:"$CurrentLog"
    }

    if ($SetAllIntl -or $SetInputLocale) {
        Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Get-Intl updated configuration"
        $CurrentLog = "$WinPEBootMediaLogs\$((Get-Date).ToString('yyMMdd-HHmmss'))-Get-Intl.log"
        Dism /image:"$MountPath" /Get-Intl /LogPath:"$CurrentLog"
    }
    #endregion
    #=================================================
    #region Apply WinRE Modifications
    if ($WimSourceType -eq 'WinRE') {
        #=================================================
        #	Wallpaper
        #=================================================
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Adding default WinRE Wallpaper $MountPath\Windows\System32\winpe.jpg"
        # Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] WinRE does not use the standard winpe.jpg and uses an all black winre.jpg"
        # Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] This step adds the default WinPE Wallpaper and modifies the Registry to point to winpe.jpg"

        $Wallpaper = '/9j/4AAQSkZJRgABAQEAYABgAAD/2wBDAAIBAQIBAQICAgICAgICAwUDAwMDAwYEBAMFBwYHBwcGBwcICQsJCAgKCAcHCg0KCgsMDAwMBwkODw0MDgsMDAz/2wBDAQICAgMDAwYDAwYMCAcIDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAz/wAARCAAgACADASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwD5vooor+sD+KwooooAKKKKACiiigD/2Q=='
        [byte[]]$Bytes = [convert]::FromBase64String($Wallpaper)

        [System.IO.File]::WriteAllBytes("$env:TEMP\winpe.jpg", $Bytes)
        $null = robocopy "$env:TEMP" "$MountPath\Windows\System32" winpe.jpg /b /ndl /np /r:0 /w:0 /xj /njh /njs /mt:128 /LOG+:$WinPEBootMediaLogs\Robocopy.log

        #[System.IO.File]::WriteAllBytes("$env:TEMP\winre.jpg",$Bytes)
        #Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Injecting $MountPath\Windows\System32\winre.jpg"
        #$null = robocopy "$env:TEMP" "$MountPath\Windows\System32" winre.jpg /b /ndl /np /r:0 /w:0 /xj /LOG+:$WinPEBootMediaLogs\Robocopy.log

        # Inject the WinRE Wallpaper Driver
        $InfFile = "$env:Temp\Set-WinREWallpaper.inf"
        $null = New-Item -Path $InfFile -Force
        Set-Content -Path $InfFile -Value $InfWinpeJpg -Encoding Unicode -Force
        $null = Add-WindowsDriver -Path $MountPath -Driver $InfFile -ForceUnsigned
        #=================================================
        # Add WirelessConnect.exe
        # https://oliverkieselbach.com/
        # https://github.com/okieselbach/Helpers
        # https://msendpointmgr.com/2018/03/06/build-a-winpe-with-wireless-support/
        # 
        $CacheWirelessConnect = Join-Path $OSDWorkspaceCachePath "BootImage-WirelessConnect"
        $WirelessConnectExe = "$CacheWirelessConnect\WirelessConnect.exe"
        if (-not (Test-Path -Path $CacheWirelessConnect)) {
            Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Creating WirelessConnect cache at $CacheWirelessConnect"
            New-Item -Path $CacheWirelessConnect -ItemType Directory -Force | Out-Null
        }
        if (-not (Test-Path -Path $WirelessConnectExe)) {
            Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] WirelessConnect: Adding cache content at $CacheWirelessConnect"
            Save-WebFile -SourceUrl 'https://github.com/okieselbach/Helpers/raw/master/WirelessConnect/WirelessConnect/bin/Release/WirelessConnect.exe' -DestinationDirectory $CacheWirelessConnect | Out-Null
        }
        if (Test-Path $WirelessConnectExe) {
            Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] WirelessConnect: Using cache content at $WirelessConnectExe"
            Copy-Item -Path $WirelessConnectExe -Destination "$MountPath\Windows\System32\WirelessConnect.exe" -Force | Out-Null
            $global:BootMedia.AddWirelessConnect = $true
        }
        #=================================================
    }
    #endregion
    #=================================================
    #region Add Microsoft DaRT
    $CacheMicrosoftDaRT = Join-Path $OSDWorkspaceCachePath 'BootImage-MicrosoftDaRT'

    # MicrosoftDartCab
    $MicrosoftDartCab = "$env:ProgramFiles\Microsoft DaRT\v10\Toolsx64.cab"
    if (Test-Path $MicrosoftDartCab) {
        if (-not (Test-Path "$CacheMicrosoftDaRT\Toolsx64.cab")) {
            Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Microsoft DaRT: Adding cache content at $CacheMicrosoftDaRT"
            if (-not (Test-Path $CacheMicrosoftDaRT)) {
                New-Item -Path $CacheMicrosoftDaRT -ItemType Directory -Force | Out-Null
            }
            Copy-Item -Path $MicrosoftDartCab -Destination "$CacheMicrosoftDaRT\Toolsx64.cab" -Force | Out-Null
        }
    }

    $MicrosoftDartCab = "$CacheMicrosoftDaRT\Toolsx64.cab"
    if (Test-Path $MicrosoftDartCab) {
        if ($BootMediaName -match 'public') {
            Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Microsoft DaRT: Not adding Microsoft DaRT for Public BootMedia"
        }
        else {
            Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Microsoft DaRT: Using cache content at $MicrosoftDartCab"
            expand.exe "$MicrosoftDartCab" -F:*.* "$MountPath" | Out-Null
            $global:BootMedia.AddMicrosoftDaRT = $true
        }
    }
    else {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Microsoft DaRT: Install Microsoft Desktop Optimization Pack to add Microsoft DaRT to BootImage"
    }

    # MicrosoftDartConfig
    $MicrosoftDartConfig = "$env:ProgramFiles\Microsoft Deployment Toolkit\Templates\DartConfig8.dat"
    if (Test-Path $MicrosoftDartConfig) {
        if (-not (Test-Path "$CacheMicrosoftDaRT\DartConfig.dat")) {
            Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Microsoft DaRT Config: Adding cache content at $CacheMicrosoftDaRT"
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
    #endregion
    #=================================================
    #region Add AzCopy10
    # Get started with AzCopy
    # https://learn.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-v10?tabs=dnf

    $CacheAzCopy = Join-Path $OSDWorkspaceCachePath "BootImage-AzCopy"
    if (-not (Test-Path -Path $CacheAzCopy)) {
        Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] AzCopy: Adding cache content at $CacheAzCopy"
        New-Item -Path $CacheAzCopy -ItemType Directory -Force | Out-Null
    }
    else {
        Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] AzCopy: Using cache content at $CacheAzCopy"
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] To update AzCopy, delete the $CacheAzCopy directory."
    }

    # amd64
    if (-not (Test-Path "$CacheAzCopy\amd64")) {
        $Uri = $Global:PSModuleOSDWorkspace.azcopy.amd64
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
        $Uri = $Global:PSModuleOSDWorkspace.azcopy.arm64
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
        $global:BootMedia.AddAzCopy = $true
    }
    #endregion
    #=================================================
    #region	Add 7zip
    # Thanks Gary Blok
    $Cache7zip = Join-Path $OSDWorkspaceCachePath "BootImage-7zip"
    if (-not (Test-Path -Path $Cache7zip)) {
        Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] 7zip: Adding cache content at $Cache7zip"
        New-Item -Path $Cache7zip -ItemType Directory -Force | Out-Null
    }
    else {
        Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] 7zip: Using cache content at $Cache7zip"
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] To update 7zip, delete the $Cache7zip directory."
    }

    if (-not (Test-Path -Path "$Cache7zip\7zr.exe")) {
        $DownloadStandalone = $Global:PSModuleOSDWorkspace.sevenzip.standalone
        Save-WebFile -SourceUrl $DownloadStandalone -DestinationDirectory $Cache7zip
    }

    if (-not (Test-Path -Path "$Cache7zip\7za")) {
        $DownloadExtra = $Global:PSModuleOSDWorkspace.sevenzip.extra
        $DownloadExtraResult = Save-WebFile -SourceUrl $DownloadExtra -DestinationDirectory $Cache7zip
        $null = & "$Cache7zip\7zr.exe" x "$($DownloadExtraResult.FullName)" -o"$Cache7zip\7za" -y
    }

    if ($Architecture -eq 'amd64') {
        Copy-Item -Path "$Cache7zip\7za\x64\*" -Destination "$MountPath\Windows\System32" -Recurse -Force
        $global:BootMedia.AddZip = $true
    }
    if ($Architecture -eq 'arm64') {
        Copy-Item -Path "$Cache7zip\7za\arm64\*" -Destination "$MountPath\Windows\System32" -Recurse -Force
        $global:BootMedia.AddZip = $true
    }
    #endregion
    #=================================================
    #region PowerShell 5.1
    #TODO Get this to work offline
    $CachePowerShellModules = Join-Path $OSDWorkspaceCachePath "BootImage-PowerShell\Modules"

    # Save PackageManagement
    if (-not (Test-Path -Path "$CachePowerShellModules\PackageManagement")) {
        Save-Module -Name PackageManagement -Path $CachePowerShellModules -Force
    }
    Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] PowerShell: Add PackageManagement"
    $null = Copy-PSModuleToWindowsImage -Name 'PackageManagement' -Path $MountPath

    # Save PowerShellGet
    if (-not (Test-Path -Path "$CachePowerShellModules\PowerShellGet")) {
        Save-Module -Name PowerShellGet -Path $CachePowerShellModules -Force
    }
    Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] PowerShell: Add PowerShellGet"
    $null = Copy-PSModuleToWindowsImage -Name 'PowerShellGet' -Path $MountPath

    Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] PowerShell: Add Environment Variables"
    $InfFile = "$env:Temp\Set-WinPEEnvironment.inf"
    New-Item -Path $InfFile -Force
    Set-Content -Path $InfFile -Value $InfEnvironment -Encoding Unicode -Force
    $null = Add-WindowsDriver -Path $MountPath -Driver $InfFile -ForceUnsigned

    Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] PowerShell: Set WinPE ExecutionPolicy to Bypass"
    Set-WindowsImageExecutionPolicy -Path $MountPath -ExecutionPolicy Bypass | Out-Null
    #endregion
    #=================================================
    #region Add PowerShell 7
    <#
    $CachePowerShell7 = Join-Path $OSDWorkspaceCachePath "BootImage-PowerShell"
    if (-not (Test-Path -Path $CachePowerShell7)) {
        Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] PowerShell 7: Adding cache content at $CachePowerShell7"
        New-Item -Path $CachePowerShell7 -ItemType Directory -Force | Out-Null
    }
    else {
        Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] PowerShell 7: Using cache content at $CachePowerShell7"
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] To update PowerShell 7, delete the $CachePowerShell7 directory."
    }

    # Download amd64
    $DownloadUri = $Global:PSModuleOSDWorkspace.pwsh.amd64
    $DownloadFile = Split-Path $DownloadUri -Leaf
    if (-not (Test-Path "$CachePowerShell7\$DownloadFile")) {
        $DownloadResult = Save-WebFile -SourceUrl $DownloadUri -DestinationDirectory $CachePowerShell7
        Start-Sleep -Seconds 2
    }
    # Install amd64
    if ($Architecture -eq 'amd64') {
        if (Test-Path "$CachePowerShell7\$DownloadFile") {
            Expand-Archive -Path "$CachePowerShell7\$DownloadFile" -DestinationPath "$MountPath\Program Files\PowerShell\7" -Force
            $global:BootMedia.AddPwsh = (Get-Item -Path "$CachePowerShell7\$DownloadFile").BaseName
        }
    }

    # Download arm64
    $DownloadUri = $Global:PSModuleOSDWorkspace.pwsh.arm64
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
            $global:BootMedia.AddPwsh = (Get-Item -Path "$CachePowerShell7\$DownloadFile").BaseName
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
    #>
    #endregion
    #=================================================
    #region OSDeploy Save-WindowsImage
    Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Save Windows Image"
    $CurrentLog = "$WinPEBootMediaLogs\$((Get-Date).ToString('yyMMdd-HHmmss'))-Save-WindowsImage.log"
    $WindowsImage | Save-WindowsImage -LogPath $CurrentLog | Out-Null
    #Save-WindowsImage -Path $MountPath -LogPath $CurrentLog | Out-Null
    #endregion
    #=================================================
    #region OSDeploy Remove winpeshl.ini
    $Winpeshl = "$MountPath\Windows\System32\winpeshl.ini"
    if (Test-Path $Winpeshl) {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Removing WinRE $Winpeshl"
        Remove-Item -Path $Winpeshl -Force
    }
    #endregion
    #=================================================
    #region OSDeploy Registry Fixes
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Modifying WinPE CMD and PowerShell Console settings"
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] This increases the buffer and sets the window metrics and default fonts"

    $RegConsole | Out-File "$env:TEMP\RegistryConsole.reg" -Encoding ascii -Width 2000 -Force
    Invoke-Exe reg load HKLM\Default "$MountPath\Windows\System32\Config\DEFAULT"
    Invoke-Exe reg import "$env:TEMP\RegistryConsole.reg"

    # reg add "HKLM\Default\Control Panel\Colors" /t REG_SZ /v Background /d "0 99 177" /f

    <#
    # Scaling
    reg add "HKLM\Default\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /t REG_SZ /v "X:\Windows\System32\WirelessConnect.exe" /d "~ HIGHDPIAWARE" /f
    reg add "HKLM\Default\Control Panel\Desktop" /t REG_DWORD /v LogPixels /d 96 /f
    reg add "HKLM\Default\Control Panel\Desktop" /v Win8DpiScaling /t REG_DWORD /d 0x00000001 /f
    reg add "HKLM\Default\Control Panel\Desktop" /v DpiScalingVer /t REG_DWORD /d 0x00001018 /f
    #>

    # Unload Registry
    Start-Sleep -Seconds 3
    Invoke-Exe reg unload HKLM\Default | Out-Null
    #endregion
    #=================================================
    #region BootDriver
    if ($BootDriver) {
        Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Applying BootDriver selection using Add-WindowsDriver"
        foreach ($DriverPath in $BootDriver) {
            if (Test-Path $DriverPath) {
                # $ArchName = ( $DriverPath.FullName -split '\\' | Select-Object -last 3 ) -join '\'
                # Write-Host -ForegroundColor DarkGray $ArchName
                Write-Host -ForegroundColor DarkGray "$DriverPath"
                $CurrentLog = "$WinPEBootMediaLogs\$((Get-Date).ToString('yyMMdd-HHmmss'))-Add-WindowsDriver.log"
        
                try {
                    # Dism
                    #dism /Image:$MountPath /Add-Driver /Driver:"$($DriverPath.FullName)" /Recurse /ForceUnsigned
                    #Start-Process Dism -ArgumentList "/Image:""$MountPath""", '/Add-Package', "/PackagePath:""$PackageFile""", '/IgnoreCheck' -NoNewWindow -Wait

                    # PowerShell
                    $null = $WindowsImage | Add-WindowsDriver -Driver $DriverPath -ForceUnsigned -Recurse -LogPath "$CurrentLog" -ErrorAction Stop
                }
                catch {
                    Write-Error -Message 'Driver failed to install. Root cause may be found in the following Dism Log'
                    Write-Error -Message "$CurrentLog"
                }
            }
            else {
                Write-Warning "BootDriver $DriverPath (not found)"
            }
        }
    }
    #endregion
    #=================================================
    #region BootImageFile
    if ($BootImageFile) {
        foreach ($Item in $BootImageFile) {
            if (Test-Path $Item) {
                if ($Item -match '.zip') {
                    Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Expanding BootImage Files from $Item"
                    Expand-Archive -Path $Item -Destination $MountPath
                }
                else {
                    Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Copying BootImage Files from $Item"
                    robocopy "$Item" "$MountPath" *.* /s /b /ndl /nfl /np /ts /tee /r:0 /w:0 /xx /xj /njs /mt:128
                }
            }
            else {
                Write-Warning "BootImage File $Item (not found)"
            }
        }
    }
    #endregion
    #=================================================
    #region BootImageScript
    if ($BootImageScript) {
        foreach ($Item in $BootImageScript) {
            if (Test-Path $Item) {
                Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Calling BootImage Script from $Item"
                & "$Item"
            }
            else {
                Write-Warning "BootImage Script $Item (not found)"
            }
        }
    }
    #endregion
    #=================================================
    #region BootStartnet
    if ($BootStartnet) {
        foreach ($Item in $BootStartnet) {
            if (Test-Path $Item) {
                Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Copying Startnet.cmd from $Item"
                Copy-Item -Path $Item -Destination "$MountPath\Windows\System32\Startnet.cmd" -Force -Verbose
            }
            else {
                Write-Warning "BootImage Startnet $Item (not found)"
            }
        }
    }
    #endregion
    #=================================================
    #region AddPackagePath
    <#
    if ($PackagePath) {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Apply PackagePath"

        $Params = @{
            ErrorAction = 'Stop'
            LogLevel    = 'WarningsInfo'
            LogPath     = "$WinPEBootMediaLogs\$((Get-Date).ToString('yyMMdd-HHmmss'))-CumulativeUpdate.log"
            PackagePath = $CumulativeUpdate
            Path        = $MountPath
            Verbose     = $true
        }

        Write-Host -ForegroundColor Yellow 'Add-WindowsPackage -PackagePath' $Params.PackagePath
        Write-Host -ForegroundColor DarkGray '-Path' $Params.Path
        Write-Host -ForegroundColor DarkGray '-LogPath' $Params.LogPath

        try {
            Add-WindowsPackage @Params
        }
        catch {
            Write-Warning $PSItem.Exception.Message
        }
        finally {
            $Error.Clear()
        }

        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Updated WinPE Information"
        $WinPEUpdatedInfo = Get-RegCurrentVersion -Path $MountPath
        $WinPEUpdatedInfo

        if ($RegKeyCurrentVersion.UBR -eq $WinPEUpdatedInfo.UBR) {
            Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] There were no changes to the UBR after applying the Cumulative Update"
            Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] You should verify that the Cumulative Update is for this version of WinPE"
            Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Boot Files will not be updated"
            Write-Host
            Start-Sleep -Seconds 15
        }
        else {
            Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Update Boot Files"

            #bootmgr.efi
            Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Source: $MountPath\Windows\boot\efi\bootmgr.efi"
            Write-Host -ForegroundColor Yellow "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Destination: $MediaPath\bootmgr.efi"
            Copy-Item -Path "$MountPath\Windows\boot\efi\bootmgr.efi" -Destination "$MediaPath\bootmgr.efi" -Force

            #bootmgfw.efi
            Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Source: $MountPath\Windows\boot\efi\bootmgfw.efi"
            Write-Host -ForegroundColor Yellow "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Destination: $MediaPath\EFI\Boot\bootx64.efi"
            Copy-Item -Path "$MountPath\Windows\boot\efi\bootmgfw.efi" -Destination "$MediaPath\EFI\Boot\bootx64.efi" -Force

            #bootmgfw.efi Microsoft Guidance: https://learn.microsoft.com/en-us/windows/deployment/update/media-dynamic-update#update-winpe
            #Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Source: $MountPath\Windows\boot\efi\bootmgfw.efi"
            #Write-Host -ForegroundColor Yellow "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Destination: $MediaPath\bootmgfw.efi"
            #Copy-Item -Path "$MountPath\Windows\boot\efi\bootmgfw.efi" -Destination "$MediaPath\bootmgfw.efi" -Force
        }

        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Dism Component Cleanup"

        $CurrentLog = "$WinPEBootMediaLogs\$((Get-Date).ToString('yyMMdd-HHmmss'))-DismComponentCleanup.log"
        #$CommandLine = "Dism /Cleanup-Image /StartComponentCleanup /Image:`"$MountPath`" /LogPath:`"$CurrentLog`""
        Write-Host -ForegroundColor Yellow "Dism /Image:`"$MountPath`""
        Write-Host -ForegroundColor DarkGray '/Cleanup-Image /StartComponentCleanup'
        Write-Host -ForegroundColor DarkGray "/LogPath:`"$CurrentLog`""

        DISM /Image:"$MountPath" /Cleanup-Image /StartComponentCleanup /LogPath:"$CurrentLog"
    }
    #>
    #endregion
    #=================================================
    #region AddImageUpdates
    <#
    if ($BootMediaUpdates) {
        foreach ($Item in $BootMediaUpdates) {
            Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Applying BootMedia Updates $($Item.FullName)"

            $Params = @{
                ErrorAction = 'Stop'
                LogLevel    = 'WarningsInfo'
                LogPath     = "$WinPEBootMediaLogs\$((Get-Date).ToString('yyMMdd-HHmmss'))-$($Item.Name).log"
                PackagePath = $($Item.FullName)
                Path        = $MountPath
                Verbose     = $true
            }

            Write-Host -ForegroundColor Yellow 'Add-WindowsPackage -PackagePath' $Params.PackagePath
            Write-Host -ForegroundColor DarkGray '-Path' $Params.Path
            Write-Host -ForegroundColor DarkGray '-LogPath' $Params.LogPath

            try {
                Add-WindowsPackage @Params
            }
            catch {
                Write-Warning $PSItem.Exception.Message
            }
            finally {
                $Error.Clear()
            }
        }

        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Updated WinPE Information"
        $WinPEUpdatedInfo = Get-RegCurrentVersion -Path $MountPath
        $WinPEUpdatedInfo

        if ($RegKeyCurrentVersion.UBR -eq $WinPEUpdatedInfo.UBR) {
            Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] There were no changes to the UBR after applying the Cumulative Update"
            Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] You should verify that the Cumulative Update is for this version of WinPE"
            Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Boot Files will not be updated"
            Write-Host
            Start-Sleep -Seconds 15
        }
        else {
            Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Update Boot Files"

            #bootmgr.efi
            Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Source: $MountPath\Windows\boot\efi\bootmgr.efi"
            Write-Host -ForegroundColor Yellow "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Destination: $MediaPath\bootmgr.efi"
            Copy-Item -Path "$MountPath\Windows\boot\efi\bootmgr.efi" -Destination "$MediaPath\bootmgr.efi" -Force

            #bootmgfw.efi
            Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Source: $MountPath\Windows\boot\efi\bootmgfw.efi"
            Write-Host -ForegroundColor Yellow "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Destination: $MediaPath\EFI\Boot\bootx64.efi"
            Copy-Item -Path "$MountPath\Windows\boot\efi\bootmgfw.efi" -Destination "$MediaPath\EFI\Boot\bootx64.efi" -Force

            #bootmgfw.efi Microsoft Guidance: https://learn.microsoft.com/en-us/windows/deployment/update/media-dynamic-update#update-winpe
            #Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Source: $MountPath\Windows\boot\efi\bootmgfw.efi"
            #Write-Host -ForegroundColor Yellow "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Destination: $MediaPath\bootmgfw.efi"
            #Copy-Item -Path "$MountPath\Windows\boot\efi\bootmgfw.efi" -Destination "$MediaPath\bootmgfw.efi" -Force
        }

        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Dism Component Cleanup"

        $CurrentLog = "$WinPEBootMediaLogs\$((Get-Date).ToString('yyMMdd-HHmmss'))-DismComponentCleanup.log"
        #$CommandLine = "Dism /Cleanup-Image /StartComponentCleanup /Image:`"$MountPath`" /LogPath:`"$CurrentLog`""
        Write-Host -ForegroundColor Yellow "Dism /Image:`"$MountPath`""
        Write-Host -ForegroundColor DarkGray '/Cleanup-Image /StartComponentCleanup'
        Write-Host -ForegroundColor DarkGray "/LogPath:`"$CurrentLog`""

        DISM /Image:"$MountPath" /Cleanup-Image /StartComponentCleanup /LogPath:"$CurrentLog"
    }
    #>
    #endregion
    #=================================================
    #region Export Get-WindowsDrivers
    Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Export Get-WindowsDriver [$BootMediaCorePath\winpe-WindowsDriver.json]"
    $WindowsDriver = $WindowsImage | Get-WindowsDriver
    if ($WindowsDriver) {
        $WindowsDriver | Select-Object * | Export-Clixml -Path "$BootMediaCorePath\winpe-WindowsDriver.xml" -Force
        $WindowsDriver | ConvertTo-Json | Out-File "$BootMediaCorePath\winpe-WindowsDriver.json" -Encoding utf8 -Force
        $WindowsDriver | Sort-Object ProviderName, CatalogFile, Version | Select-Object ProviderName, CatalogFile, Version, Date, ClassName, BootCritical, Driver, @{ Name = 'FileRepository'; Expression = { ($_.OriginalFileName.split('\')[-2]) } } | Format-Table -AutoSize
    }
    #endregion
    #=================================================
    #region Export Get-WindowsPackage
    Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Export Get-WindowsPackage [$BootMediaCorePath\winpe-WindowsPackage.json]"
    $WindowsPackage = $WindowsImage | Get-WindowsPackage
    if ($WindowsPackage) {
        $WindowsPackage | Select-Object * | Export-Clixml -Path "$BootMediaCorePath\winpe-WindowsPackage.xml" -Force
        $WindowsPackage | ConvertTo-Json | Out-File "$BootMediaCorePath\winpe-WindowsPackage.json" -Encoding utf8 -Force
        $WindowsPackage | Sort-Object -Property PackageName | Format-Table -AutoSize
    }
    #endregion
    #=================================================
    #region Export Get-RegCurrentVersion
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Export Get-RegCurrentVersion [$BootMediaCorePath\winpe-RegCurrentVersion.json]"
    $RegKeyCurrentVersion = Get-RegCurrentVersion -Path $MountPath
    $RegKeyCurrentVersion | Out-File "$BootMediaCorePath\winpe-RegCurrentVersion.txt"
    $RegKeyCurrentVersion | Export-Clixml -Path "$BootMediaCorePath\winpe-RegCurrentVersion.xml"
    $RegKeyCurrentVersion | ConvertTo-Json | Out-File "$BootMediaCorePath\winpe-RegCurrentVersion.json" -Encoding utf8 -Force
    #endregion
    #=================================================
    #region AddCustomPackage
    <#
    if ($AddCustomPackage) {
        Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Adding Custom Library Packages"
        foreach ($Item in $AddCustomPackage) {
            Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Custom Package: $($Item.Name)"
            Get-ChildItem -Path $($Item.FullName) -ErrorAction SilentlyContinue | Where-Object Name -match 'bootimage.ps1' | ForEach-Object {
                Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] call $($_.FullName)"
                & $($_.FullName)
            }
            Get-ChildItem -Path "$($Item.FullName)" -ErrorAction SilentlyContinue | Where-Object Name -match 'bootmedia.ps1' | ForEach-Object {
                Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] call $($_.FullName)"
                & $($_.FullName)
            }
            #Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Calling BootMedia Script from $Item"
            #& "$Item"
        }
    }
    #>
    #endregion
    #=================================================
    #region Get Startnet.cmd Content
    if (Test-Path "$MountPath\Windows\System32\startnet.cmd") {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Startnet.cmd Content"
        $global:BootMedia.StartnetContent = Get-Content -Path "$MountPath\Windows\System32\startnet.cmd" -Raw
        $global:BootMedia.StartnetContent
    }
    #endregion
    #=================================================
    #region Get winpeshl.ini Content
    if (Test-Path "$MountPath\Windows\System32\winpeshl.ini") {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] winpeshl.ini Content"
        $global:BootMedia.WinpeshlContent = Get-Content -Path "$MountPath\Windows\System32\winpeshl.ini" -Raw
        $global:BootMedia.WinpeshlContent
    }
    #endregion
    #=================================================
    #region Dismount Windows Image and Save
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Dismount-WindowsImage Save"
    $WindowsImage | Dismount-MyWindowsImage -Save
    #endregion
    #=================================================
    #region Export WIM to reduce the size
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Export-WindowsImage"
    $buildMediaSourcesPathBootWim = Join-Path $buildMediaSourcesPath 'boot.wim'
    $buildMediaSourcesPathExportWim = Join-Path $buildMediaSourcesPath 'export.wim'
    if (Test-Path $buildMediaSourcesPathExportWim) {
        Remove-Item -Path $buildMediaSourcesPathExportWim -Force -ErrorAction Stop | Out-Null
    }
    $CurrentLog = "$WinPEBootMediaLogs\$((Get-Date).ToString('yyMMdd-HHmmss'))-Export-WindowsImage.log"
    if ($WimSourceType -eq 'WinPE') {
        Export-WindowsImage -SourceImagePath $buildMediaSourcesPathBootWim -SourceIndex 1 -DestinationImagePath $buildMediaSourcesPathExportWim -LogPath $CurrentLog | Out-Null
    }
    else {
        # Export-WindowsImage -SourceImagePath $buildMediaSourcesPathBootWim -SourceIndex 1 -DestinationImagePath $buildMediaSourcesPathExportWim -DestinationName 'Microsoft Windows PE (x64)' -LogPath $CurrentLog | Out-Null
        Export-WindowsImage -SourceImagePath $buildMediaSourcesPathBootWim -SourceIndex 1 -DestinationImagePath $buildMediaSourcesPathExportWim -LogPath $CurrentLog | Out-Null
    }
    Remove-Item -Path $buildMediaSourcesPathBootWim -Force -ErrorAction Stop | Out-Null
    Rename-Item -Path $buildMediaSourcesPathExportWim -NewName 'boot.wim' -Force -ErrorAction Stop | Out-Null

    Get-WindowsImage -ImagePath $buildMediaSourcesPathBootWim -Index 1 | Export-Clixml -Path "$BootMediaCorePath\winpe-WindowsImage.xml"
    Get-WindowsImage -ImagePath $buildMediaSourcesPathBootWim -Index 1 | ConvertTo-Json | Out-File "$BootMediaCorePath\winpe-WindowsImage.json" -Encoding utf8

    Copy-Item -Path $(Join-Path $buildMediaSourcesPath 'boot.wim') -Destination $(Join-Path $buildMediaSourcesPathEX 'boot.wim') -Force -ErrorAction Stop | Out-Null
    #endregion
    #=================================================
    #region BootMediaFile
    if ($BootMediaFile) {
        foreach ($Item in $BootMediaFile) {
            if ($Item -match '.zip') {
                Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Expanding BootMedia Files from $Item"
                Expand-Archive -Path $Item -Destination $MediaPath
                if ($MediaPathEX) {
                    Expand-Archive -Path $Item -Destination $MediaPathEX
                }
            }
            else {
                Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Copying BootMedia Files from $Item"
                robocopy "$Item" "$MediaPath" *.* /s /b /ndl /nfl /np /ts /tee /r:0 /w:0 /xx /xj /njs /mt:128
                if ($MediaPathEX) {
                    robocopy "$Item" "$MediaPathEX" *.* /s /b /ndl /nfl /np /ts /tee /r:0 /w:0 /xx /xj /njs /mt:128
                }
            }
        }
    }
    #endregion
    #=================================================
    #region BootMediaScript
    if ($BootMediaScript) {
        foreach ($Item in $BootMediaScript) {
            if (Test-Path $Item -ErrorAction SilentlyContinue) {
                Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Call BootMedia Script [$Item]"
                & "$Item"
            }
            else {
                Write-Warning "BootMedia Script $Item (not found)"
            }
        }
    }
    #endregion
    #=================================================
    #region Build Bootable ISOs
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Creating bootable ISOs [$BootMediaRootPath]"
    New-WindowsAdkISO -MediaPath $MediaPath -IsoFileName $BootMediaIsoName -IsoLabel $BootMediaIsoLabel -WindowsAdkRoot $WindowsAdkRootPath | Out-Null
    if ($MediaPathEX) {
        New-WindowsAdkISO -MediaPath $MediaPathEX -IsoFileName $BootMediaIsoNameEX -IsoLabel $BootMediaIsoLabel -WindowsAdkRoot $WindowsAdkRootPath | Out-Null
    }
    #endregion
    #=================================================
    #region Set BootMedia
    #Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Set-OSDCloudTemplate -Name $BootMediaName"
    <#
    $WinPE = [PSCustomObject]@{
        BuildDate = (Get-Date).ToString('yyyy.MM.dd.HHmmss')
        Version = [Version](Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).Version
    }
    $WinPE | ConvertTo-Json | Out-File "$BootMediaRootPath\core\winpe-WindowsImage.json" -Encoding ascii -Width 2000 -Force
    #>
    #Set-OSDCloudTemplate -Name $BootMediaName
    #endregion
    #=================================================
    #region UpdateUSB
    if ($UpdateUSB) {
        Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Update USB WinPE Partition"
        $WinpeVolumes = Get-USBVolume | Where-Object { $_.FileSystemLabel -eq 'WinPE' }
        if ($WinpeVolumes) {
            foreach ($volume in $WinpeVolumes) {
                if (Test-Path -Path "$($volume.DriveLetter):\") {
                    #Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] ROBOCOPY $BootMediaRootPath\Media $($volume.DriveLetter):\"
                    robocopy "$BootMediaRootPath\Media" "$($volume.DriveLetter):\" *.* /e /ndl /njs /np /r:0 /w:0 /xd "$RECYCLE.BIN" 'System Volume Information' /xj
                }
            }
        }
        else {
            Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Unable to find a USB Partition WinPE label to update"
        }
    }
    #endregion
    #=================================================
    #region Complete
    # Add the final ADKPaths information to the bootmedia object
    $global:BootMedia.AdkPaths = $WindowsAdkPaths

    # Add the final WinPE information to the bootmedia object
    $global:BootMedia.PEInfo = $GetWindowsImage

    Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Exporting BootMedia Profile to $BootMediaCorePath\gv-bootmediaprofile.json"
    $global:BootMediaProfile | Export-Clixml -Path "$BootMediaCorePath\gv-bootmediaprofile.xml" -Force
    $global:BootMediaProfile | ConvertTo-Json | Out-File "$BootMediaCorePath\gv-bootmediaprofile.json" -Encoding utf8 -Force

    Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Exporting BootMedia Properties to $BootMediaCorePath\gv-bootmedia.json"
    $global:BootMedia | Export-Clixml -Path "$BootMediaCorePath\gv-bootmedia.xml" -Force
    $global:BootMedia | ConvertTo-Json | Out-File "$BootMediaCorePath\gv-bootmedia.json" -Encoding utf8 -Force

    [Net.ServicePointManager]::SecurityProtocol = $currentVersionTls

    if ($PSversionTable.PSEdition -ne 'Core') {
        $ProgressPreference = $currentProgressPref
    }
    
    $null = Get-OSDWorkspaceBootMedia

    $buildEndTime = Get-Date
    $buildTimeSpan = New-TimeSpan -Start $BuildStartTime -End $buildEndTime
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] $($MyInvocation.MyCommand.Name) completed in $($buildTimeSpan.ToString("mm' minutes 'ss' seconds'"))"
    Stop-Transcript
    #endregion
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}