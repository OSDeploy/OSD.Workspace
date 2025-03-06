function New-OSDWorkspaceBootMedia {
    <#
    .SYNOPSIS
        Creates a new OSDWorkspace BootMedia.

    .DESCRIPTION
        This function creates a new OSDWorkspace BootMedia by copying the selected BootImage and adding the Windows ADK Optional Components.
        The BootMedia is created in the OSDWorkspace BootMedia directory.

    .PARAMETER Name
        Name to append to the BootMedia Id.

    .PARAMETER Languages
        Windows ADK Languages to add to the BootImage. Default is en-US.

    .PARAMETER SetAllIntl
        Sets all International settings in WinPE to the specified language. Default is en-US.

    .PARAMETER SetInputLocale
        Sets the default InputLocale in WinPE to the specified Input Locale. Default is en-US.

    .PARAMETER Timezone
        Set the WinPE TimeZone. Default is the current TimeZone.

    .PARAMETER AdkSelect
        Select the Windows ADK version to use if multiple versions are present in the cache.

    .PARAMETER AdkSkipOCs
        Skip adding the Windows ADK Optional Components. Useful for quick testing of the Library.

    .PARAMETER AdkWinPE
        Uses the Windows ADK winpe.wim instead of an imported BootImage.

    .PARAMETER Architecture
        Architecture of the BootImage. This is automatically set when selected a existing BootImage. This is required when using the Windows ADK winpe.wim.

    .PARAMETER UpdateUSB
        Update a OSDWorkspace USB drive with the new BootMedia.

    .INPUTS
        None.

        You cannot pipe input to this cmdlet.

    .OUTPUTS
        None.

        This function does not return any output.

    .EXAMPLE
        New-OSDWorkspaceBootMedia -Name 'MyBootMedia' -Architecture 'amd64'
        Creates a new OSDWorkspace 'amd64' BootMedia with the name 'MyBootMedia'.

    .EXAMPLE
        New-OSDWorkspaceBootMedia -Name 'MyBootMedia' -Architecture 'arm64'
        Creates a new OSDWorkspace 'arm64' BootMedia with the name 'MyBootMedia'.

    .EXAMPLE
        New-OSDWorkspaceBootMedia -Name 'MyBootMedia' -Architecture 'amd64' -AdkWinPE
        Creates a new OSDWorkspace 'amd64' BootMedia using the Windows ADK winpe.wim with the name 'MyBootMedia'.

    .EXAMPLE
        New-OSDWorkspaceBootMedia -Name 'MyBootMedia' -Architecture 'arm64' -AdkSelect
        Creates a new OSDWorkspace 'arm64' BootMedia with the name 'MyBootMedia' and prompts to select the Windows ADK version to use.

    .EXAMPLE
        New-OSDWorkspaceBootMedia -Name 'MyBootMedia' -Architecture 'amd64' -Languages 'en-US', 'fr-FR'
        Creates a new OSDWorkspace BootMedia with the name 'MyBootMedia', architecture 'amd64' and languages 'en-US' and 'fr-FR'.

    .LINK
    https://github.com/OSDeploy/OSD.Workspace/blob/main/docs/New-OSDWorkspaceBootMedia.md

    .NOTES
    David Segura
    #>
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
        #Update a OSDWorkspace USB drive with the new BootMedia.
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
        'x64-Support'
        'MDAC'
    )
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
    $currentProgressPref = $ProgressPreference
    $ProgressPreference = 'SilentlyContinue'

    $regproxy = Get-ItemProperty -Path 'Registry::HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings'
    $proxy = $regproxy.ProxyServer

    if ($proxy -and -not ([System.Net.Webrequest]::DefaultWebProxy).Address -and $regproxy.ProxyEnable) {
        [System.Net.Webrequest]::DefaultWebProxy = New-object System.Net.WebProxy $proxy
        [System.Net.Webrequest]::DefaultWebProxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
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
        $null = robocopy.exe "$WindowsAdkInstallPath" "$WindowsAdkRootPath" *.* /e /z /ndl /nfl /np /r:0 /w:0 /xj /mt:128
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
        #$BootMediaName = "$BootMediaName $Name"
    }

    $WindowsAdkPaths.WimSourcePath = $BootImageWimPath
    
    $BootMediaIsoName = 'BootMedia.iso'
    $BootMediaIsoNameEX = 'BootMediaEX.iso'
    $BootMediaRootPath = Join-Path $(Get-OSDWorkspaceBootMediaPath) $BootMediaName
    $global:BootMediaCorePath = "$BootMediaRootPath\core"
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
        MediaPath          = Join-Path $BootMediaRootPath 'BootMedia'
        MediaPathEX        = $null
        MountPath          = $null
        Name               = [System.String]$Name
        OSDCachePath       = $OSDWorkspaceCachePath
        PEVersion          = $GetWindowsImage.Version
        SetAllIntl         = [System.String]$SetAllIntl
        SetInputLocale     = [System.String]$SetInputLocale
        StartnetContent    = [System.String]$StartnetContent
        TimeZone           = [System.String]$TimeZone
        UpdateUSB          = $UpdateUSB
        WimSourceType      = $WimSourceType
        WinpeshlContent    = [System.String]$WinpeshlContent
    }
    #endregion
    #=================================================
    #   Point of No Return
    #=================================================
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Use the `$global:BootMedia variable in your PowerShell Scripts for this BootMedia configuration"
    $global:BootMedia | Out-Host
    Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Press CTRL+C to cancel"
    pause
    $BuildStartTime = Get-Date
    #=================================================
    #region Start Main
    $global:BootMediaLogs = "$BootMediaTempPath\logs"
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] BootMediaCorePath: $BootMediaCorePath"

    if (-not (Test-Path $BootMediaRootPath)) {
        $null = New-Item -Path $BootMediaRootPath -ItemType Directory -Force
    }
    if (-not (Test-Path $BootMediaLogs)) {
        $null = New-Item -Path $BootMediaLogs -ItemType Directory -Force | Out-Null
    }

    $Transcript = "$((Get-Date).ToString('yyMMdd-HHmmss'))-New-OSDWorkspaceBootMedia.log"
    Start-Transcript -Path (Join-Path $BootMediaLogs $Transcript) -ErrorAction SilentlyContinue
    #endregion
    #=================================================
    #region Copy Core
    if ($BootImageCorePath) {
        if (Test-Path $BootImageCorePath) {
            Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Hydrate $BootMediaCorePath"
            $null = robocopy.exe "$BootImageCorePath" "$BootMediaCorePath" *.json /nfl /ndl /np /r:0 /w:0 /xj /mt:128 /LOG+:$BootMediaLogs\Robocopy.log
            $null = robocopy.exe "$BootImageCorePath" "$BootMediaCorePath" *.xml /nfl /ndl /np /r:0 /w:0 /xj /mt:128 /LOG+:$BootMediaLogs\Robocopy.log
        }
    }

    $ImportId = @{id = $BootMediaName }
    $ImportId | ConvertTo-Json | Out-File "$BootMediaCorePath\id.json" -Encoding utf8
    #endregion
    #=================================================
    #region Build Media
    $MediaPath = $global:BootMedia.MediaPath
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] MediaPath: $MediaPath"
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Hydrate $MediaPath"
    $null = robocopy.exe "$($WindowsAdkPaths.PathWinPEMedia)" "$MediaPath" *.* /mir /b /ndl /np /r:0 /w:0 /xj /njs /mt:128 /LOG+:$BootMediaLogs\Robocopy.log

    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Copying $BootImageCorePath\os-boot\DVD\EFI\en-US\efisys.bin"
    Copy-Item -Path "$BootImageCorePath\os-boot\DVD\EFI\en-US\efisys.bin" -Destination "$MediaPath\EFI\Microsoft\Boot\efisys.bin" -Force -ErrorAction SilentlyContinue

    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Copying $BootImageCorePath\os-boot\DVD\EFI\en-US\efisys_noprompt.bin"
    Copy-Item -Path "$BootImageCorePath\os-boot\DVD\EFI\en-US\efisys_noprompt.bin" -Destination "$MediaPath\EFI\Microsoft\Boot\efisys_noprompt.bin" -Force -ErrorAction SilentlyContinue

    $Fonts = @('malgunn_boot.ttf', 'meiryon_boot.ttf', 'msjhn_boot.ttf', 'msyhn_boot.ttf', 'segoen_slboot.ttf')
    foreach ($Font in $Fonts) {
        if (Test-Path "$BootImageCorePath\os-boot\Fonts\$Font") {
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Copying $BootImageCorePath\os-boot\Fonts\$Font"
            Copy-Item -Path "$BootImageCorePath\os-boot\Fonts\$Font" -Destination "$MediaPath\EFI\Microsoft\Boot\Fonts\$Font" -Force -ErrorAction SilentlyContinue
        }
    }
    #endregion
    #=================================================
    #region Build MediaEX
    if (Test-Path "$BootImageCorePath\os-boot\EFI_EX") {
        $global:BootMedia.MediaPathEX = Join-Path $BootMediaRootPath 'BootMediaEX'
        $MediaPathEX = $global:BootMedia.MediaPathEX
        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] MediaPathEX: $MediaPathEX"
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Hydrate $MediaPathEX"
        $null = robocopy.exe "$($WindowsAdkPaths.PathWinPEMedia)" "$MediaPathEX" *.* /mir /b /ndl /np /r:0 /w:0 /xj /mt:128 /LOG+:$BootMediaLogs\Robocopy.log

        Write-Host -ForegroundColor DarkGreen "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Mitigate CVE-2022-21894 Secure Boot Security Feature Bypass Vulnerability aka BlackLotus"
        Remove-Item -Path "$MediaPathEX\EFI\Microsoft\Boot\Fonts" -Recurse -Force
        if (-not (Test-Path "$MediaPathEX\EFI\Microsoft\Boot\Fonts")) {
            New-Item -Path "$MediaPathEX\EFI\Microsoft\Boot\Fonts" -ItemType Directory -Force | Out-Null
        }

        Copy-Item -Path "$BootImageCorePath\os-boot\EFI_EX\bootmgr_ex.efi" -Destination "$MediaPathEX\bootmgr.efi" -Force -ErrorAction SilentlyContinue
        Copy-Item -Path "$BootImageCorePath\os-boot\EFI_EX\bootmgfw_ex.efi" -Destination "$MediaPathEX\EFI\Boot\bootx64.efi" -Force -ErrorAction SilentlyContinue
        Copy-Item -Path "$BootImageCorePath\os-boot\Fonts_EX\chs_boot_EX.ttf" -Destination "$MediaPathEX\EFI\Microsoft\Boot\Fonts\chs_boot.ttf" -Force -ErrorAction SilentlyContinue
        Copy-Item -Path "$BootImageCorePath\os-boot\Fonts_EX\cht_boot_EX.ttf" -Destination "$MediaPathEX\EFI\Microsoft\Boot\Fonts\cht_boot.ttf" -Force -ErrorAction SilentlyContinue
        Copy-Item -Path "$BootImageCorePath\os-boot\Fonts_EX\jpn_boot_EX.ttf" -Destination "$MediaPathEX\EFI\Microsoft\Boot\Fonts\jpn_boot.ttf" -Force -ErrorAction SilentlyContinue
        Copy-Item -Path "$BootImageCorePath\os-boot\Fonts_EX\kor_boot_EX.ttf" -Destination "$MediaPathEX\EFI\Microsoft\Boot\Fonts\kor_boot.ttf" -Force -ErrorAction SilentlyContinue
        Copy-Item -Path "$BootImageCorePath\os-boot\Fonts_EX\malgun_boot_EX.ttf" -Destination "$MediaPathEX\EFI\Microsoft\Boot\Fonts\malgun_boot.ttf" -Force -ErrorAction SilentlyContinue
        Copy-Item -Path "$BootImageCorePath\os-boot\Fonts_EX\malgunn_boot_EX.ttf" -Destination "$MediaPathEX\EFI\Microsoft\Boot\Fonts\malgunn_boot.ttf" -Force -ErrorAction SilentlyContinue
        Copy-Item -Path "$BootImageCorePath\os-boot\Fonts_EX\meiryo_boot_EX.ttf" -Destination "$MediaPathEX\EFI\Microsoft\Boot\Fonts\meiryo_boot.ttf" -Force -ErrorAction SilentlyContinue
        Copy-Item -Path "$BootImageCorePath\os-boot\Fonts_EX\meiryon_boot_EX.ttf" -Destination "$MediaPathEX\EFI\Microsoft\Boot\Fonts\meiryon_boot.ttf" -Force -ErrorAction SilentlyContinue
        Copy-Item -Path "$BootImageCorePath\os-boot\Fonts_EX\msjh_boot_EX.ttf" -Destination "$MediaPathEX\EFI\Microsoft\Boot\Fonts\msjh_boot.ttf" -Force -ErrorAction SilentlyContinue
        Copy-Item -Path "$BootImageCorePath\os-boot\Fonts_EX\msjhn_boot_EX.ttf" -Destination "$MediaPathEX\EFI\Microsoft\Boot\Fonts\msjhn_boot.ttf" -Force -ErrorAction SilentlyContinue
        Copy-Item -Path "$BootImageCorePath\os-boot\Fonts_EX\msyh_boot_EX.ttf" -Destination "$MediaPathEX\EFI\Microsoft\Boot\Fonts\msyh_boot.ttf" -Force -ErrorAction SilentlyContinue
        Copy-Item -Path "$BootImageCorePath\os-boot\Fonts_EX\msyhn_boot_EX.ttf" -Destination "$MediaPathEX\EFI\Microsoft\Boot\Fonts\msyhn_boot.ttf" -Force -ErrorAction SilentlyContinue
        Copy-Item -Path "$BootImageCorePath\os-boot\Fonts_EX\segmono_boot_EX.ttf" -Destination "$MediaPathEX\EFI\Microsoft\Boot\Fonts\segmono_boot.ttf" -Force -ErrorAction SilentlyContinue
        Copy-Item -Path "$BootImageCorePath\os-boot\Fonts_EX\segoe_slboot_EX.ttf" -Destination "$MediaPathEX\EFI\Microsoft\Boot\Fonts\segoe_slboot.ttf" -Force -ErrorAction SilentlyContinue
        Copy-Item -Path "$BootImageCorePath\os-boot\Fonts_EX\segoen_slboot_EX.ttf" -Destination "$MediaPathEX\EFI\Microsoft\Boot\Fonts\segoen_slboot.ttf" -Force -ErrorAction SilentlyContinue
        Copy-Item -Path "$BootImageCorePath\os-boot\Fonts_EX\wgl4_boot_EX.ttf" -Destination "$MediaPathEX\EFI\Microsoft\Boot\Fonts\wgl4_boot.ttf" -Force -ErrorAction SilentlyContinue
        Copy-Item -Path "$BootImageCorePath\os-boot\DVD_EX\EFI\en-US\efisys_EX.bin" -Destination "$MediaPathEX\EFI\Microsoft\Boot\efisys.bin" -Force -ErrorAction SilentlyContinue
        Copy-Item -Path "$BootImageCorePath\os-boot\DVD_EX\EFI\en-US\efisys_noprompt_EX.bin" -Destination "$MediaPathEX\EFI\Microsoft\Boot\efisys_noprompt.bin" -Force -ErrorAction SilentlyContinue
    }
    else {
        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Does not exist $BootImageCorePath\os-boot\EFI_EX"
        $MediaPathEX = $null
    }
    #endregion
    #=================================================
    #region Build Sources
    $global:BuildMediaSourcesPath = Join-Path $MediaPath 'sources'
    if (-not (Test-Path "$BuildMediaSourcesPath")) {
        New-Item -Path "$BuildMediaSourcesPath" -ItemType Directory -Force -ErrorAction Stop | Out-Null
    }
    $buildMediaSourcesBootwimPath = Join-Path $BuildMediaSourcesPath 'boot.wim'
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Hydrate $buildMediaSourcesBootwimPath"
    Copy-Item -Path $WindowsAdkPaths.WimSourcePath -Destination $buildMediaSourcesBootwimPath -Force -ErrorAction Stop | Out-Null

    if (!(Test-Path $buildMediaSourcesBootwimPath)) {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Unknown issue copying $buildMediaSourcesBootwimPath"
        Stop-Transcript
        Break
    }
    attrib -s -h -r $BuildMediaSourcesPath
    attrib -s -h -r $buildMediaSourcesBootwimPath

    if ($MediaPathEX) {
        $global:BuildMediaSourcesPathEX = Join-Path $MediaPathEX 'sources'
        if (-not (Test-Path "$BuildMediaSourcesPathEX")) {
            New-Item -Path "$BuildMediaSourcesPathEX" -ItemType Directory -Force -ErrorAction Stop | Out-Null
        }
        attrib -s -h -r $BuildMediaSourcesPathEX
    }
    #endregion
    #=================================================
    #region BootImage Mount
    $global:WindowsImage = Mount-MyWindowsImage $buildMediaSourcesBootwimPath
    $MountPath = $WindowsImage.Path
    $global:BootMedia.MountPath = $MountPath
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] MountPath: $MountPath"
    #endregion
    #=================================================
    #region BootImage Registry Information
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Get WinPE HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
    $RegKeyCurrentVersion = Get-RegCurrentVersion -Path $MountPath
    $RegKeyCurrentVersion | Out-Host
    #endregion
    #=================================================
    #region Export Get-WindowsPackage
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Export $BootMediaCorePath\pe-WindowsPackage.xml"
    $WindowsPackage = $WindowsImage | Get-WindowsPackage
    if ($WindowsPackage) {
        $WindowsPackage | Select-Object * | Export-Clixml -Path "$BootMediaCorePath\pe-WindowsPackage.xml" -Force
    }
    #endregion
    #=================================================
    #region Adding OS Files
    if ($BootImageOSFilesPath) {
        if (Test-Path $BootImageOSFilesPath) {
            Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Adding OS Files from $BootImageOSFilesPath"
            $null = robocopy.exe "$BootImageOSFilesPath" "$MountPath" *.* /s /b /ndl /nfl /np /ts /r:0 /w:0 /xf bcp47*.dll /xx /xj /mt:128 /LOG+:$BootMediaLogs\Robocopy.log
        }
    }
    #endregion
    #=================================================
    if ($AdkSkipOCs -eq $false) {
        $WinPEOCs = $WindowsAdkPaths.WinPEOCs
        #=================================================
        #region OSDeploy Install Default en-us Language
        Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Adding ADK Packages for Language en-us"
        $Lang = 'en-us'

        foreach ($Package in $WinpeOCPackages) {
            $PackageFile = "$WinPEOCs\WinPE-$Package.cab"
            if (Test-Path $PackageFile) {
                Write-Host -ForegroundColor Gray "$PackageFile"
                $PackageName = "Add-WindowsPackage-WinPE-$Package"
                $CurrentLog = "$BootMediaLogs\$((Get-Date).ToString('yyMMdd-HHmmss'))-$PackageName.log"

                try {
                    $WindowsImage | Add-WindowsPackage -PackagePath $PackageFile -LogPath "$CurrentLog" -ErrorAction Stop | Out-Null
                }
                catch {
                    if ($_.Exception.ErrorCode -eq '-2148468766') {
                        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] 0x800f081e CBS_E_NOT_APPLICABLE The Windows ADK version you are using does not seem to support the WinPE version you are trying to service"
                    }
                    if ($_.Exception.ErrorCode -eq '-2146498512') {
                        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] 0x800f0830 CBS_E_IMAGE_UNSERVICEABLE The specified image is no longer serviceable and may be corrupted. Discard the modified image and start again"
                    }
                    <#
                    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] If this package is not essential, it is recommended to try again without this package as the Windows Image may now be unserviceable"
                    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Log: $CurrentLog"
                    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] ErrorCode: $($_.Exception.ErrorCode)"
                    #>
                }
            }
            else {
                Write-Host -ForegroundColor DarkGray "$PackageFile (not present)"
            }
        }

        # Bail if the PowerShell package did not install
        if (-NOT ($WindowsImage | Get-WindowsPackage | Where-Object { $_.PackageName -match 'PowerShell' })) {
            Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Powershell Optional Component is not installed. Required ADK Packages did not install properly"
            Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Make sure the Windows ADK version you are using supports the WinRE version you are trying to service"
            Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Build will continue so you can review the logs for more information"
            Start-Sleep -Seconds 15
        }

        $PackageFile = "$WinPEOCs\$Lang\lp.cab"
        if (Test-Path $PackageFile) {
            Write-Host -ForegroundColor Gray "$PackageFile"
            $PackageName = "Add-WindowsPackage-WinPE-lp_$Lang"
            $CurrentLog = "$BootMediaLogs\$((Get-Date).ToString('yyMMdd-HHmmss'))-$PackageName.log"

            try {
                $WindowsImage | Add-WindowsPackage -PackagePath $PackageFile -LogPath "$CurrentLog" -ErrorAction Stop | Out-Null
            }
            catch {
                if ($_.Exception.ErrorCode -eq '-2148468766') {
                    Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] 0x800f081e CBS_E_NOT_APPLICABLE The Windows ADK version you are using does not seem to support the WinPE version you are trying to service"
                }
                if ($_.Exception.ErrorCode -eq '-2146498512') {
                    Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] 0x800f0830 CBS_E_IMAGE_UNSERVICEABLE The specified image is no longer serviceable and may be corrupted. Discard the modified image and start again"
                }
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
                $CurrentLog = "$BootMediaLogs\$((Get-Date).ToString('yyMMdd-HHmmss'))-$PackageName.log"

                try {
                    $WindowsImage | Add-WindowsPackage -PackagePath $PackageFile -LogPath "$CurrentLog" -ErrorAction Stop | Out-Null
                }
                catch {
                    if ($_.Exception.ErrorCode -eq '-2148468766') {
                        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] 0x800f081e CBS_E_NOT_APPLICABLE The Windows ADK version you are using does not seem to support the WinPE version you are trying to service"
                    }
                    if ($_.Exception.ErrorCode -eq '-2146498512') {
                        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] 0x800f0830 CBS_E_IMAGE_UNSERVICEABLE The specified image is no longer serviceable and may be corrupted. Discard the modified image and start again"
                    }
                }
            }
            else {
                Write-Host -ForegroundColor DarkGray "$PackageFile (not present)"
            }
        }
        #endregion
        #=================================================
        #region OSDeploy Save-WindowsImage
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Saving Windows Image at $MountPath"
        $CurrentLog = "$BootMediaLogs\$((Get-Date).ToString('yyMMdd-HHmmss'))-Save-WindowsImage.log"
        $WindowsImage | Save-WindowsImage -LogPath $CurrentLog | Out-Null
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
                $CurrentLog = "$BootMediaLogs\$((Get-Date).ToString('yyMMdd-HHmmss'))-$PackageName.log"
    
                try {
                    $WindowsImage | Add-WindowsPackage -PackagePath $PackageFile -LogPath "$CurrentLog" -ErrorAction Stop | Out-Null
                }
                catch {
                    if ($_.Exception.ErrorCode -eq '-2148468766') {
                        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] 0x800f081e CBS_E_NOT_APPLICABLE The Windows ADK version you are using does not seem to support the WinPE version you are trying to service"
                    }
                    if ($_.Exception.ErrorCode -eq '-2146498512') {
                        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] 0x800f0830 CBS_E_IMAGE_UNSERVICEABLE The specified image is no longer serviceable and may be corrupted. Discard the modified image and start again"
                    }
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
                    $CurrentLog = "$BootMediaLogs\$((Get-Date).ToString('yyMMdd-HHmmss'))-$PackageName.log"
                
                    try {
                        $WindowsImage | Add-WindowsPackage -PackagePath $PackageFile -LogPath "$CurrentLog" -ErrorAction Stop | Out-Null
                    }
                    catch {
                        if ($_.Exception.ErrorCode -eq '-2148468766') {
                            Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] 0x800f081e CBS_E_NOT_APPLICABLE The Windows ADK version you are using does not seem to support the WinPE version you are trying to service"
                        }
                        if ($_.Exception.ErrorCode -eq '-2146498512') {
                            Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] 0x800f0830 CBS_E_IMAGE_UNSERVICEABLE The specified image is no longer serviceable and may be corrupted. Discard the modified image and start again"
                        }
                    }
                }
                else {
                    Write-Host -ForegroundColor DarkGray "$PackageFile (not present)"
                }
            }

            # Generates a new Lang.ini file which is used to define the language packs inside the image
            if ( (Test-Path -Path "$MountPath\sources\lang.ini") ) {
                Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Updating lang.ini"
                $CurrentLog = "$BootMediaLogs\$((Get-Date).ToString('yyMMdd-HHmmss'))-Gen-LangINI.log"
                dism.exe /image:"$MountPath" /Gen-LangINI /distribution:"$MountPath" /LogPath:"$CurrentLog"
            }
        
            Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Save Windows Image"
            $CurrentLog = "$BootMediaLogs\$((Get-Date).ToString('yyMMdd-HHmmss'))-Save-WindowsImage.log"
            Save-WindowsImage -Path $MountPath -LogPath $CurrentLog | Out-Null
        }
        #endregion
    }
    #=================================================
    Step-BootImageDismSettings
    Step-BootImageAddWallpaper
    Step-BootImagePowerShellUpdate
    Step-BootImageAddWirelessConnect
    Step-BootImageAddMicrosoftDart
    Step-BootImageAddAzCopy
    Step-BootImageAddZip
    Step-BootImageAddPwsh
    Step-BootImageWindowsImageSave
    Step-BootImageRemoveWinpeshl
    Step-BootImageConsoleSettings
    Step-BootImageLibraryBootDriver
    Step-BootImageLibraryBootImageFile
    Step-BootImageLibraryBootImageScript
    Step-BootImageLibraryBootStartnet
    Step-BootImageExportWindowsDriverPE
    Step-BootImageExportWindowsPackagePE
    Step-BootImageRegCurrentVersionExport
    Step-BootImageDismGetIntl
    Step-BootImageGetContentStartnet
    Step-BootImageGetContentWinpeshl
    Step-BootImageWindowsImageDismount
    Step-BootImageWindowsImageExport
    #=================================================
    Step-BootMediaLibraryBootMediaFile
    Step-BootMediaLibraryBootMediaScript
    #=================================================
    #region Build Bootable ISO
    $BootIsoPath = Join-Path $BootMediaRootPath 'BootISO'
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Creating bootable ISO [$BootIsoPath]"
    if (-NOT(Test-Path $BootIsoPath)) { New-Item -Path $BootIsoPath -ItemType Directory -Force | Out-Null}
    $Params = @{
        MediaPath = $MediaPath
        IsoFileName = $BootMediaIsoName
        IsoLabel = $BootMediaIsoLabel
        WindowsAdkRoot = $WindowsAdkRootPath
        IsoDirectory = $BootIsoPath
    }
    New-WindowsAdkISO @Params | Out-Null

    if ($MediaPathEX) {
        $Params = @{
            MediaPath      = $MediaPathEX
            IsoFileName    = $BootMediaIsoNameEX
            IsoLabel       = $BootMediaIsoLabel
            WindowsAdkRoot = $WindowsAdkRootPath
            IsoDirectory   = $BootIsoPath
        }
        New-WindowsAdkISO @Params | Out-Null
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
                    robocopy "$BootMediaRootPath\Media" "$($volume.DriveLetter):\" *.* /e /ndl /np /r:0 /w:0 /xd "$RECYCLE.BIN" 'System Volume Information' /xj
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

    # Restore TLS settings
    [Net.ServicePointManager]::SecurityProtocol = $currentVersionTls
    $ProgressPreference = $currentProgressPref


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