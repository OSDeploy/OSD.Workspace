function Build-OSDWorkspaceWinPE {
    <#
    .SYNOPSIS
        Creates a new customized WinPE build in the OSDWorkspace environment.

    .DESCRIPTION
        The Build-OSDWorkspaceWinPE function creates a new Windows Preinstallation Environment (WinPE) build 
        in the OSDWorkspace build directory. The function can use either a WinRE source image or the Windows 
        Assessment and Deployment Kit (ADK) WinPE image as a base, then applies customizations including drivers,
        packages, scripts, and other settings.
        
        This function performs the following operations:
        1. Validates administrator privileges
        2. Creates necessary directory structure for the build
        3. Sources a base WinPE image (from WinRE or Windows ADK)
        4. Applies selected customizations (drivers, packages, scripts)
        5. Generates boot media in various formats (WIM, ISO, USB-ready files)
        
        Build output is stored in the C:\OSDWorkspace\Build\WinPE directory by default,
        organized by architecture and build name.

    .EXAMPLE
        Build-OSDWorkspaceWinPE -Name 'MyBootMedia' -Architecture 'amd64'
        
        Creates a new WinPE build for x64 architecture named 'MyBootMedia' using WinRE as the source.

    .EXAMPLE
        Build-OSDWorkspaceWinPE -Name 'MyBootMedia' -Architecture 'arm64'
        
        Creates a new WinPE build for ARM64 architecture named 'MyBootMedia' using WinRE as the source.

    .EXAMPLE
        Build-OSDWorkspaceWinPE -Name 'MyBootMedia' -Architecture 'amd64' -AdkUseWinPE
        
        Creates a new WinPE build for x64 architecture named 'MyBootMedia' using the Windows ADK WinPE image.

    .EXAMPLE
        Build-OSDWorkspaceWinPE -Name 'MyBootMedia' -Architecture 'arm64' -AdkSelectCacheVersion
        
        Creates a new WinPE build for ARM64 architecture named 'MyBootMedia' and prompts to select 
        which Windows ADK version to use as the source.
        
    .EXAMPLE
        Build-OSDWorkspaceWinPE -Name 'DeploymentMedia' -Verbose
        
        Creates a new WinPE build with detailed verbose output showing each step of the process.

    .OUTPUTS
        None. This function does not generate any output objects.

    .NOTES
        Author: David Segura
        Version: 1.0
        Date: April 29, 2025
        
        Prerequisites:
            - PowerShell 5.0 or higher
            - Windows 10 or higher
            - Run as Administrator
            - Windows ADK installed (if using -AdkUseWinPE or -AdkSelectCacheVersion)
            - WinRE source imported (if not using -AdkUseWinPE)
            
        The build process can take several minutes depending on the customizations applied.
    #>

    
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param (
        # Specifies a friendly name for the WinPE build.
        # This name will be used in the build directory structure and media labels.
        [Parameter(Mandatory)]
        [System.String]
        $Name,

        # Specifies the processor architecture for the WinPE build.
        # Valid values are 'amd64' (64-bit x86) and 'arm64' (64-bit ARM).
        # Default value is 'amd64'.
        [Parameter(ParameterSetName = 'Default')]
        [Parameter(Mandatory, ParameterSetName = 'ADK')]
        [ValidateSet('amd64', 'arm64')]
        [System.String]
        $Architecture,

        # Windows ADK Languages to add to the BootImage. Default is en-us.
        [ValidateSet (
            '*','ar-sa','bg-bg','cs-cz','da-dk','de-de','el-gr',
            'en-gb','en-us','es-es','es-mx','et-ee','fi-fi',
            'fr-ca','fr-fr','he-il','hr-hr','hu-hu','it-it',
            'ja-jp','ko-kr','lt-lt','lv-lv','nb-no','nl-nl',
            'pl-pl','pt-br','pt-pt','ro-ro','ru-ru','sk-sk',
            'sl-si','sr-latn-rs','sv-se','th-th','tr-tr',
            'uk-ua','zh-cn','zh-tw'
        )]
        [System.String[]]
        $Languages = 'en-us',

        # Sets all International settings in WinPE to the specified language. Default is en-US.
        [System.String]
        $SetAllIntl = 'en-us',

        # Sets the default InputLocale in WinPE to the specified Input Locale. Default is en-US.
        [System.String]
        $SetInputLocale = 'en-us',

        # Set the WinPE SetTimeZone. Default is the current SetTimeZone.
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
        $SetTimeZone = (tzutil /g),

        # Update a OSDWorkspace USB drive with the new BootMedia.
        [System.Management.Automation.SwitchParameter]
        $UpdateUSB,

        # Select the Windows ADK version to use if multiple versions are present in the cache.
        [System.Management.Automation.SwitchParameter]
        $AdkSelectCacheVersion,

        # Skip adding the Windows ADK Optional Components. Useful for quick testing of the Library.
        [System.Management.Automation.SwitchParameter]
        $AdkSkipOcPackages,

        # Uses the Windows ADK winpe.wim instead of an imported winre.wim.
        [Parameter(Mandatory, ParameterSetName = 'ADK')]
        [System.Management.Automation.SwitchParameter]
        $AdkUseWinPE
    )
    #=================================================
    $Error.Clear()
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Start"
    Initialize-OSDWorkspace
    #=================================================
    # Requires Run as Administrator
    $IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $IsAdmin ) {
        Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] This function must be Run as Administrator"
        return
    }
    #=================================================
    # Import OSD.Workspace settings
    if (-not $global:OSDWorkspace) {
        Import-OSDWorkspaceSettings
    }

    $WindowsAdkWinpePackages = $global:OSDWorkspace.adkwinpepackages
    #=================================================
    # Start Main
    $BuildDateTime = $((Get-Date).ToString('yyMMdd-HHmm'))
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Starting $($MyInvocation.MyCommand.Name)"
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
    if ($AdkSkipOcPackages.IsPresent) {
        $AdkSkipOcPackages = $true
    }
    else {
        $AdkSkipOcPackages = $false
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
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Windows ADK install version is $WindowsAdkInstallVersion"
        }
        if ($WindowsAdkInstallPath) {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Windows ADK install path is $WindowsAdkInstallPath"
        }
    }
    else {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Windows ADK is not installed."
    }
    #endregion
    #=================================================
    #region Get and Update the ADK Cache
    $WSCachePath = $OSDWorkspace.paths.cache
    $WSAdkVersionsPath = $OSDWorkspace.paths.adk_versions
    #endregion
    #=================================================
    #region If ADK is installed then we need to update the cache
    if ($IsWindowsAdkInstalled) {
        $WindowsAdkRootPath = Join-Path $WSAdkVersionsPath $WindowsAdkInstallVersion
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Windows ADK cache content is $WindowsAdkRootPath"
        $null = robocopy.exe "$WindowsAdkInstallPath" "$WindowsAdkRootPath" *.* /e /z /ndl /nfl /np /r:0 /w:0 /xj /mt:128
    }
    else {
        Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Cannot update the ADK cache because the ADK is not installed"
        $AdkSelectCacheVersion = $true
        Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] AdkSelectCacheVersion: $AdkSelectCacheVersion"
    }
    #endregion
    #=================================================
    #region Get the WindowsAdkCacheOptions
    $WindowsAdkCacheOptions = $null
    if (Test-Path $WSAdkVersionsPath) {
        $WindowsAdkCacheOptions = Get-ChildItem -Path "$WSAdkVersionsPath\*" -Directory -ErrorAction SilentlyContinue | Sort-Object -Property Name
    }
    #endregion
    #=================================================
    #region ADK is not installed and not present in the cache
    if (($IsWindowsAdkInstalled -eq $false) -and (-not $WindowsAdkCacheOptions)) {
        Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Windows ADK is not installed"
        Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] ADK cache does not contain an offline Windows ADK"
        Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Windows ADK will need to be installed before using this function"
        Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] https://learn.microsoft.com/en-us/windows-hardware/get-started/adk-install"
        return
    }
    #endregion
    #=================================================
    #region There is no usable ADK in the cache
    if ($WindowsAdkCacheOptions.Count -eq 0) {
        # Something is wrong, there should always be at least one ADK in the cache
        Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] ADK cache does not contain an offline Windows ADK"
        Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Windows ADK will need to be installed before using this function"
        return
    }
    #endregion
    #=================================================
    #region ADK is available by this point and we either have 1 or more to select from
    if ($WindowsAdkCacheOptions.Count -eq 1) {
        # Only one version of the ADK is present in the cache, so this must be used
        $WindowsAdkRootPath = $WindowsAdkCacheOptions.FullName
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] ADK cache contains 1 offline Windows ADK option"
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Using ADK cache at $WindowsAdkCacheSelected"

        # Can't select an ADK Version if there is only one
        $AdkSelectCacheVersion = $false
    }
    elseif ($WindowsAdkCacheOptions.Count -gt 1) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] $($WindowsAdkCacheOptions.Count) Windows ADK options are available to select from the ADK cache"
        if ($AdkSelectCacheVersion) {
            Write-Host -ForegroundColor DarkCyan "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Select a Windows ADK option and press OK (Cancel to Exit)"
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] To remove a Windows ADK option, delete one of the ADK cache directories in $WSAdkVersionsPath"
            $WindowsAdkCacheSelected = $WindowsAdkCacheOptions | Select-Object FullName | Sort-Object FullName -Descending | Out-GridView -Title 'Select a Windows ADK to use and press OK (Cancel to Exit)' -OutputMode Single
            if ($WindowsAdkCacheSelected) {
                $WindowsAdkRootPath = $WindowsAdkCacheSelected.FullName
            }
            else {
                Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Unable to set the ADK cache path"
                return
            }
        }
        else {
            Write-Host -ForegroundColor DarkCyan "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Select a different Windows ADK with the -AdkSelectCacheVersion switch"
        }
    }
    else {
        Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Something is wrong you should not be here"
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
    if ($AdkUseWinPE) {
        Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Using WinPE from Windows ADK"
        $WimSourceType = 'WinPE'
    }
    else {
        Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Using WinRE from Select-OSDWSWinRESource"
        $WimSourceType = 'WinRE'
        if ($Architecture) {
            $GetWindowsImage = Select-OSDWSWinRESource -Architecture $Architecture
        }
        else {
            $GetWindowsImage = Select-OSDWSWinRESource
        }

        if ($GetWindowsImage.Count -eq 0) {
            # There are no images to run
            return
        }

        $Architecture = $GetWindowsImage.Architecture
        $ImportImageCorePath = $GetWindowsImage.Path + '\.core'
        $ImportImageOSFilesPath = $GetWindowsImage.Path + '\.core\os-files'

        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Using Recovery Image at $($GetWindowsImage.ImagePath)"
        Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Architecture: $Architecture"
        Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] ImportImageCorePath: $ImportImageCorePath"
        Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] ImportImageOSFilesPath: $ImportImageOSFilesPath"
    }
    #endregion
    #=================================================
    #region Get ADK Paths
    if (($Architecture -notmatch 'amd64') -and ($Architecture -notmatch 'arm64')) {
        Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Unknown architecture $Architecture"
        return
    }

    $WindowsAdkPaths = Get-WindowsAdkPaths -Architecture $Architecture -AdkRoot $WindowsAdkRootPath -WarningAction SilentlyContinue

    if (-not $WindowsAdkPaths) {
        Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Something is wrong you should not be here"
        return
    }
    if ($WimSourceType -eq 'WinPE') {
        $GetWindowsImage = Get-WindowsImage -ImagePath $($WindowsAdkPaths.WimSourcePath) -Index 1
        $ImportImageWimPath = $GetWindowsImage.ImagePath
        $MediaName = "$($BuildDateTime)-$($Architecture)"
        $MediaIsoLabel = $($BuildDateTime)
    }
    elseif ($WimSourceType -eq 'WinRE') {
        $ImportImageWimPath = $GetWindowsImage.ImagePath
        $ImportImageRootPath = $GetWindowsImage.Path
        $MediaName = "$($BuildDateTime)-$($Architecture)"
        $MediaIsoLabel = $($BuildDateTime)
    }

    # Append the Name to the MediaName
    if ($Name) {
        #$MediaName = "$MediaName $Name"
    }

    $WindowsAdkPaths.WimSourcePath = $ImportImageWimPath
    
    $MediaIsoName = 'BootMedia.iso'
    $MediaIsoNameEX = 'BootMediaEX.iso'
    $MediaRootPath = Join-Path $($OSDWorkspace.paths.build_windows_pe) $MediaName
    $global:BuildMediaCorePath = "$MediaRootPath\.core"
    $BuildMediaTempPath = "$MediaRootPath\.temp"
    $global:BuildMediaLogsPath = "$BuildMediaTempPath\logs"
    #endregion
    #=================================================
    #region Select-OSDWSWinPEBuildProfile
    $MyBuildProfile = $null
    $MyBuildProfile = Select-OSDWSWinPEBuildProfile
    #endregion
    #=================================================
    #region Select-OSDWSWinPEBuildDriver
    $WinPEDriver = $null
    if (-not $MyBuildProfile) {
        $OSDWorkspaceWinPEDriver= Select-OSDWSWinPEBuildDriver -Architecture $Architecture

        if ($OSDWorkspaceWinPEDriver) {
            $WinPEDriver = ($OSDWorkspaceWinPEDriver| Select-Object -ExpandProperty FullName)
        }
    }
    #endregion
    #=================================================
    #region Select-OSDWSWinPEBuildScript
    $WinPEAppScript = $null
    $WinPEScript = $null
    $WinPEMediaScript = $null
    if (-not $MyBuildProfile) {
        $OSDWorkspaceWinPEScript = @()
        $OSDWorkspaceWinPEScript = Select-OSDWSWinPEBuildScript

        if ($OSDWorkspaceWinPEScript | Where-Object { $_.Type -eq 'winpe-appscript' }) {
            $WinPEAppScript = ($OSDWorkspaceWinPEScript | Where-Object { $_.Type -eq 'winpe-appscript' } | Select-Object -ExpandProperty FullName)
        }
        if ($OSDWorkspaceWinPEScript | Where-Object { $_.Type -eq 'winpe-script' }) {
            $WinPEScript = ($OSDWorkspaceWinPEScript | Where-Object { $_.Type -eq 'winpe-script' } | Select-Object -ExpandProperty FullName)
        }
        if ($OSDWorkspaceWinPEScript | Where-Object { $_.Type -eq 'winpe-mediascript' }) {
            $WinPEMediaScript = ($OSDWorkspaceWinPEScript | Where-Object { $_.Type -eq 'winpe-mediascript' } | Select-Object -ExpandProperty FullName)
        }
    }
    #endregion
    #=================================================
    #region MyBuildProfile
    if ($MyBuildProfile) {
        $global:BuildProfile = $null
        $global:BuildProfile = Get-Content $MyBuildProfile.FullName -Raw | ConvertFrom-Json
        $WinPEDriver = $global:BuildProfile.WinPEDriver
        $WinPEAppScript = $global:BuildProfile.WinPEAppScript
        $WinPEScript = $global:BuildProfile.WinPEScript
        $WinPEMediaScript = $global:BuildProfile.WinPEMediaScript
        [System.String[]]$Languages = $global:BuildProfile.Languages
        $SetAllIntl = $global:BuildProfile.SetAllIntl
        $SetInputLocale = $global:BuildProfile.SetInputLocale
        $SetTimeZone = $global:BuildProfile.SetTimeZone
        $MyBuildProfilePath = $MyBuildProfile.FullName
    }
    else {
        $global:BuildProfile = $null
        $global:BuildProfile = [ordered]@{
            WinPEDriver = $WinPEDriver
            WinPEAppScript = $WinPEAppScript
            WinPEScript = $WinPEScript
            WinPEMediaScript = $WinPEMediaScript
            Languages          = [System.String[]]$Languages
            SetAllIntl         = [System.String]$SetAllIntl
            SetInputLocale     = [System.String]$SetInputLocale
            SetTimeZone        = [System.String]$SetTimeZone
        }

        $BuildProfilePath = $OSDWorkspace.paths.winpe_buildprofile

        if (-not (Test-Path $BuildProfilePath)) {
            $null = New-Item -Path $BuildProfilePath -ItemType Directory -Force
        }

        $MyBuildProfilePath = "$BuildProfilePath\$Name.json"

        Write-Host -ForegroundColor DarkCyan "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Exporting BootMedia Profile to $MyBuildProfilePath"
        $global:BuildProfile | ConvertTo-Json -Depth 5 -WarningAction SilentlyContinue | Out-File $MyBuildProfilePath -Encoding utf8 -Force
    }
    #endregion
    #=================================================
    #region BuildProfile
    $global:BuildMedia = $null
    $global:BuildMedia = [ordered]@{
        AdkInstallPath          = $WindowsAdkInstallPath
        AdkInstallVersion       = $WindowsAdkInstallVersion
        AdkSkipOcPackages         = $AdkSkipOcPackages
        AdkRootPath             = $WindowsAdkRootPath
        Architecture            = [System.String]$Architecture
        BuildProfile            = $MyBuildProfilePath
        ContentStartnet         = [System.String]$ContentStartnet
        ContentWinpeshl         = [System.String]$ContentWinpeshl
        InstalledApps           = @()
        ImportImageRootPath     = $ImportImageRootPath
        ImportImageWimPath      = $ImportImageWimPath
        Languages               = [System.String[]]$Languages
        WinPEAppScript          = $WinPEAppScript
        WinPEScript             = $WinPEScript
        WinPEMediaScript        = $WinPEMediaScript
        WinPEDriver             = $WinPEDriver
        MediaIsoLabel           = $MediaIsoLabel
        MediaIsoName            = $MediaIsoName
        MediaIsoNameEX          = $MediaIsoNameEX
        MediaName               = $MediaName
        MediaPath               = Join-Path $MediaRootPath 'WinPE-Media'
        MediaPathEX             = $null
        MediaRootPath           = $MediaRootPath
        MountPath               = $null
        Name                    = [System.String]$Name
        PEVersion               = $GetWindowsImage.Version
        AdkSelectCacheVersion   = $AdkSelectCacheVersion
        SetAllIntl              = [System.String]$SetAllIntl
        SetInputLocale          = [System.String]$SetInputLocale
        SetTimeZone             = [System.String]$SetTimeZone
        UpdateUSB               = [System.Boolean]$UpdateUSB
        AdkUseWinPE             = $AdkUseWinPE
        WimSourceType           = $WimSourceType
        WSCachePath             = $WSCachePath
        WSCachePathAdk          = $WSAdkVersionsPath
    }
    #endregion
    #=================================================
    #   Point of No Return
    #=================================================
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Use the `$global:BuildMedia variable in your PowerShell Scripts for this BootMedia configuration"
    $global:BuildMedia | Out-Host
    Write-Host -ForegroundColor DarkCyan "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Press CTRL+C to cancel"
    pause
    $BuildStartTime = Get-Date
    #=================================================
    #region Start Main
    if (-not (Test-Path $MediaRootPath)) {
        $null = New-Item -Path $MediaRootPath -ItemType Directory -Force
    }
    if (-not (Test-Path $BuildMediaLogsPath)) {
        $null = New-Item -Path $BuildMediaLogsPath -ItemType Directory -Force | Out-Null
    }

    $Transcript = "$((Get-Date).ToString('yyMMdd-HHmmss'))-Build-OPE.log"
    Start-Transcript -Path (Join-Path $BuildMediaLogsPath $Transcript) -ErrorAction SilentlyContinue
    #endregion
    #=================================================
    #region BuildMediaCorePath
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] BuildMediaCorePath: $BuildMediaCorePath"
    if ($ImportImageCorePath) {
        if (Test-Path $ImportImageCorePath) {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Hydrate $BuildMediaCorePath"
            $null = robocopy.exe "$ImportImageCorePath" "$BuildMediaCorePath" *.json /nfl /ndl /np /r:0 /w:0 /xj /mt:128 /LOG+:$BuildMediaLogsPath\core.log
            $null = robocopy.exe "$ImportImageCorePath" "$BuildMediaCorePath" *.xml /nfl /ndl /np /r:0 /w:0 /xj /mt:128 /LOG+:$BuildMediaLogsPath\core.log
        }
    }

    $ImportId = @{id = $MediaName }
    if (-not (Test-Path $BuildMediaCorePath)) {
        $null = New-Item -Path $BuildMediaCorePath -ItemType Directory -Force | Out-Null
    }
    $ImportId | ConvertTo-Json -Depth 5 -WarningAction SilentlyContinue | Out-File "$BuildMediaCorePath\id.json" -Encoding utf8 -Force
    #endregion
    #=================================================
    #region Build Media
    $MediaPath = $global:BuildMedia.MediaPath
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] MediaPath: $MediaPath"
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Hydrate $MediaPath"
    $null = robocopy.exe "$($WindowsAdkPaths.PathWinPEMedia)" "$MediaPath" *.* /mir /b /ndl /np /r:0 /w:0 /xj /njs /mt:128 /LOG+:$BuildMediaLogsPath\media.log

    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Copying $ImportImageCorePath\os-boot\DVD\EFI\en-US\efisys.bin"
    Copy-Item -Path "$ImportImageCorePath\os-boot\DVD\EFI\en-US\efisys.bin" -Destination "$MediaPath\EFI\Microsoft\Boot\efisys.bin" -Force -ErrorAction SilentlyContinue

    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Copying $ImportImageCorePath\os-boot\DVD\EFI\en-US\efisys_noprompt.bin"
    Copy-Item -Path "$ImportImageCorePath\os-boot\DVD\EFI\en-US\efisys_noprompt.bin" -Destination "$MediaPath\EFI\Microsoft\Boot\efisys_noprompt.bin" -Force -ErrorAction SilentlyContinue

    $Fonts = @('malgunn_boot.ttf', 'meiryon_boot.ttf', 'msjhn_boot.ttf', 'msyhn_boot.ttf', 'segoen_slboot.ttf')
    foreach ($Font in $Fonts) {
        if (Test-Path "$ImportImageCorePath\os-boot\Fonts\$Font") {
            Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Copying $ImportImageCorePath\os-boot\Fonts\$Font"
            Copy-Item -Path "$ImportImageCorePath\os-boot\Fonts\$Font" -Destination "$MediaPath\EFI\Microsoft\Boot\Fonts\$Font" -Force -ErrorAction SilentlyContinue
        }
    }
    #endregion
    #=================================================
    #region Build MediaEX
    if (Test-Path "$ImportImageCorePath\os-boot\EFI_EX") {
        $global:BuildMedia.MediaPathEX = Join-Path $MediaRootPath 'WinPE-MediaEX'
        $MediaPathEX = $global:BuildMedia.MediaPathEX
        Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] MediaPathEX: $MediaPathEX"
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Hydrate $MediaPathEX"
        $null = robocopy.exe "$($WindowsAdkPaths.PathWinPEMedia)" "$MediaPathEX" *.* /mir /b /ndl /np /r:0 /w:0 /xj /mt:128 /LOG+:$BuildMediaLogsPath\mediaex.log

        Write-Host -ForegroundColor DarkGreen "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Mitigate CVE-2022-21894 Secure Boot Security Feature Bypass Vulnerability aka BlackLotus"
        Remove-Item -Path "$MediaPathEX\EFI\Microsoft\Boot\Fonts" -Recurse -Force
        if (-not (Test-Path "$MediaPathEX\EFI\Microsoft\Boot\Fonts")) {
            New-Item -Path "$MediaPathEX\EFI\Microsoft\Boot\Fonts" -ItemType Directory -Force | Out-Null
        }

        Copy-Item -Path "$ImportImageCorePath\os-boot\EFI_EX\bootmgr_ex.efi" -Destination "$MediaPathEX\bootmgr.efi" -Force -ErrorAction SilentlyContinue
        Copy-Item -Path "$ImportImageCorePath\os-boot\EFI_EX\bootmgfw_ex.efi" -Destination "$MediaPathEX\EFI\Boot\bootx64.efi" -Force -ErrorAction SilentlyContinue
        Copy-Item -Path "$ImportImageCorePath\os-boot\Fonts_EX\chs_boot_EX.ttf" -Destination "$MediaPathEX\EFI\Microsoft\Boot\Fonts\chs_boot.ttf" -Force -ErrorAction SilentlyContinue
        Copy-Item -Path "$ImportImageCorePath\os-boot\Fonts_EX\cht_boot_EX.ttf" -Destination "$MediaPathEX\EFI\Microsoft\Boot\Fonts\cht_boot.ttf" -Force -ErrorAction SilentlyContinue
        Copy-Item -Path "$ImportImageCorePath\os-boot\Fonts_EX\jpn_boot_EX.ttf" -Destination "$MediaPathEX\EFI\Microsoft\Boot\Fonts\jpn_boot.ttf" -Force -ErrorAction SilentlyContinue
        Copy-Item -Path "$ImportImageCorePath\os-boot\Fonts_EX\kor_boot_EX.ttf" -Destination "$MediaPathEX\EFI\Microsoft\Boot\Fonts\kor_boot.ttf" -Force -ErrorAction SilentlyContinue
        Copy-Item -Path "$ImportImageCorePath\os-boot\Fonts_EX\malgun_boot_EX.ttf" -Destination "$MediaPathEX\EFI\Microsoft\Boot\Fonts\malgun_boot.ttf" -Force -ErrorAction SilentlyContinue
        Copy-Item -Path "$ImportImageCorePath\os-boot\Fonts_EX\malgunn_boot_EX.ttf" -Destination "$MediaPathEX\EFI\Microsoft\Boot\Fonts\malgunn_boot.ttf" -Force -ErrorAction SilentlyContinue
        Copy-Item -Path "$ImportImageCorePath\os-boot\Fonts_EX\meiryo_boot_EX.ttf" -Destination "$MediaPathEX\EFI\Microsoft\Boot\Fonts\meiryo_boot.ttf" -Force -ErrorAction SilentlyContinue
        Copy-Item -Path "$ImportImageCorePath\os-boot\Fonts_EX\meiryon_boot_EX.ttf" -Destination "$MediaPathEX\EFI\Microsoft\Boot\Fonts\meiryon_boot.ttf" -Force -ErrorAction SilentlyContinue
        Copy-Item -Path "$ImportImageCorePath\os-boot\Fonts_EX\msjh_boot_EX.ttf" -Destination "$MediaPathEX\EFI\Microsoft\Boot\Fonts\msjh_boot.ttf" -Force -ErrorAction SilentlyContinue
        Copy-Item -Path "$ImportImageCorePath\os-boot\Fonts_EX\msjhn_boot_EX.ttf" -Destination "$MediaPathEX\EFI\Microsoft\Boot\Fonts\msjhn_boot.ttf" -Force -ErrorAction SilentlyContinue
        Copy-Item -Path "$ImportImageCorePath\os-boot\Fonts_EX\msyh_boot_EX.ttf" -Destination "$MediaPathEX\EFI\Microsoft\Boot\Fonts\msyh_boot.ttf" -Force -ErrorAction SilentlyContinue
        Copy-Item -Path "$ImportImageCorePath\os-boot\Fonts_EX\msyhn_boot_EX.ttf" -Destination "$MediaPathEX\EFI\Microsoft\Boot\Fonts\msyhn_boot.ttf" -Force -ErrorAction SilentlyContinue
        Copy-Item -Path "$ImportImageCorePath\os-boot\Fonts_EX\segmono_boot_EX.ttf" -Destination "$MediaPathEX\EFI\Microsoft\Boot\Fonts\segmono_boot.ttf" -Force -ErrorAction SilentlyContinue
        Copy-Item -Path "$ImportImageCorePath\os-boot\Fonts_EX\segoe_slboot_EX.ttf" -Destination "$MediaPathEX\EFI\Microsoft\Boot\Fonts\segoe_slboot.ttf" -Force -ErrorAction SilentlyContinue
        Copy-Item -Path "$ImportImageCorePath\os-boot\Fonts_EX\segoen_slboot_EX.ttf" -Destination "$MediaPathEX\EFI\Microsoft\Boot\Fonts\segoen_slboot.ttf" -Force -ErrorAction SilentlyContinue
        Copy-Item -Path "$ImportImageCorePath\os-boot\Fonts_EX\wgl4_boot_EX.ttf" -Destination "$MediaPathEX\EFI\Microsoft\Boot\Fonts\wgl4_boot.ttf" -Force -ErrorAction SilentlyContinue
        Copy-Item -Path "$ImportImageCorePath\os-boot\DVD_EX\EFI\en-US\efisys_EX.bin" -Destination "$MediaPathEX\EFI\Microsoft\Boot\efisys.bin" -Force -ErrorAction SilentlyContinue
        Copy-Item -Path "$ImportImageCorePath\os-boot\DVD_EX\EFI\en-US\efisys_noprompt_EX.bin" -Destination "$MediaPathEX\EFI\Microsoft\Boot\efisys_noprompt.bin" -Force -ErrorAction SilentlyContinue
    }
    else {
        Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Does not exist $ImportImageCorePath\os-boot\EFI_EX"
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
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Hydrate $buildMediaSourcesBootwimPath"
    Copy-Item -Path $WindowsAdkPaths.WimSourcePath -Destination $buildMediaSourcesBootwimPath -Force -ErrorAction Stop | Out-Null

    if (!(Test-Path $buildMediaSourcesBootwimPath)) {
        Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Unknown issue copying $buildMediaSourcesBootwimPath"
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
    $global:BuildMedia.MountPath = $MountPath
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] MountPath: $MountPath"
    #endregion
    #=================================================
    #region BootImage Registry Information
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Get WinPE HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
    $RegKeyCurrentVersion = Get-RegCurrentVersion -Path $MountPath
    $RegKeyCurrentVersion | Out-Host
    #endregion
    #=================================================
    #region Export Get-WindowsPackage
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Export $BuildMediaCorePath\winpe-windowspackage.xml"
    $WindowsPackage = $WindowsImage | Get-WindowsPackage
    if ($WindowsPackage) {
        $WindowsPackage | Select-Object * | Export-Clixml -Path "$BuildMediaCorePath\winpe-windowspackage.xml" -Force
    }
    #endregion
    #=================================================
    #region Adding OS Files
    if ($ImportImageOSFilesPath) {
        if (Test-Path $ImportImageOSFilesPath) {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Adding OS Files from $ImportImageOSFilesPath"
            $null = robocopy.exe "$ImportImageOSFilesPath" "$MountPath" *.* /s /b /ndl /nfl /np /ts /r:0 /w:0 /xf bcp47*.dll /xx /xj /mt:128 /LOG+:$BuildMediaLogsPath\os-files.log
        }
    }
    #endregion
    #=================================================
    #region Add ADK WinPE OCs
    if ($AdkSkipOcPackages -eq $false) {
        $WinPEOCs = $WindowsAdkPaths.WinPEOCs
        #=================================================
        #region OSDeploy Install Default en-us Language
        Write-Host -ForegroundColor DarkCyan "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Adding ADK Packages for Language en-us"
        $Lang = 'en-us'

        foreach ($Package in $WindowsAdkWinpePackages) {
            $PackageFile = "$WinPEOCs\WinPE-$Package.cab"
            if (Test-Path $PackageFile) {
                Write-Host -ForegroundColor Gray "$PackageFile"
                $PackageName = "Add-WindowsPackage-WinPE-$Package"
                $CurrentLog = "$BuildMediaLogsPath\$((Get-Date).ToString('yyMMdd-HHmmss'))-$PackageName.log"

                try {
                    $WindowsImage | Add-WindowsPackage -PackagePath $PackageFile -LogPath "$CurrentLog" -ErrorAction Stop | Out-Null
                }
                catch {
                    if ($_.Exception.ErrorCode -eq '-2148468766') {
                        Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] 0x800f081e CBS_E_NOT_APPLICABLE The Windows ADK version you are using does not seem to support the WinPE version you are trying to service"
                    }
                    if ($_.Exception.ErrorCode -eq '-2146498512') {
                        Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] 0x800f0830 CBS_E_IMAGE_UNSERVICEABLE The specified image is no longer serviceable and may be corrupted. Discard the modified image and start again"
                    }
                    <#
                    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] If this package is not essential, it is recommended to try again without this package as the Windows Image may now be unserviceable"
                    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Log: $CurrentLog"
                    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] ErrorCode: $($_.Exception.ErrorCode)"
                    #>
                }
            }
            else {
                Write-Host -ForegroundColor DarkGray "$PackageFile (not present)"
            }
        }

        # Bail if the PowerShell package did not install
        if (-NOT ($WindowsImage | Get-WindowsPackage | Where-Object { $_.PackageName -match 'PowerShell' })) {
            Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Powershell Optional Component is not installed. Required ADK Packages did not install properly"
            Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Make sure the Windows ADK version you are using supports the WinRE version you are trying to service"
            Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Build will continue so you can review the logs for more information"
            Start-Sleep -Seconds 15
        }

        $PackageFile = "$WinPEOCs\$Lang\lp.cab"
        if (Test-Path $PackageFile) {
            Write-Host -ForegroundColor Gray "$PackageFile"
            $PackageName = "Add-WindowsPackage-WinPE-lp_$Lang"
            $CurrentLog = "$BuildMediaLogsPath\$((Get-Date).ToString('yyMMdd-HHmmss'))-$PackageName.log"

            try {
                $WindowsImage | Add-WindowsPackage -PackagePath $PackageFile -LogPath "$CurrentLog" -ErrorAction Stop | Out-Null
            }
            catch {
                if ($_.Exception.ErrorCode -eq '-2148468766') {
                    Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] 0x800f081e CBS_E_NOT_APPLICABLE The Windows ADK version you are using does not seem to support the WinPE version you are trying to service"
                }
                if ($_.Exception.ErrorCode -eq '-2146498512') {
                    Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] 0x800f0830 CBS_E_IMAGE_UNSERVICEABLE The specified image is no longer serviceable and may be corrupted. Discard the modified image and start again"
                }
            }
        }
        else {
            Write-Host -ForegroundColor DarkGray "$PackageFile (not present)"
        }

        foreach ($Package in $WindowsAdkWinpePackages) {
            $PackageFile = "$WinPEOCs\$Lang\WinPE-$Package`_$Lang.cab"
            if (Test-Path $PackageFile) {

                Write-Host -ForegroundColor Gray "$PackageFile"
                $PackageName = "Add-WindowsPackage-WinPE-$Package`_$Lang"
                $CurrentLog = "$BuildMediaLogsPath\$((Get-Date).ToString('yyMMdd-HHmmss'))-$PackageName.log"

                try {
                    $WindowsImage | Add-WindowsPackage -PackagePath $PackageFile -LogPath "$CurrentLog" -ErrorAction Stop | Out-Null
                }
                catch {
                    if ($_.Exception.ErrorCode -eq '-2148468766') {
                        Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] 0x800f081e CBS_E_NOT_APPLICABLE The Windows ADK version you are using does not seem to support the WinPE version you are trying to service"
                    }
                    if ($_.Exception.ErrorCode -eq '-2146498512') {
                        Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] 0x800f0830 CBS_E_IMAGE_UNSERVICEABLE The specified image is no longer serviceable and may be corrupted. Discard the modified image and start again"
                    }
                }
            }
            else {
                Write-Host -ForegroundColor DarkGray "$PackageFile (not present)"
            }
        }
        #endregion
        #=================================================
        Step-BuildMediaWindowsImageSave
        #=================================================
        #region OSDeploy Install Selected Languages
        if ($Languages -contains '*') {
            $Languages = Get-ChildItem $WinPEOCs -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -ne 'en-us' } | Select-Object -ExpandProperty Name
        }
        foreach ($Lang in $Languages) {
            if ($Lang -eq 'en-us') { Continue }
            Write-Host -ForegroundColor DarkCyan "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Adding $Lang ADK Packages"
            $PackageFile = "$WinPEOCs\$Lang\lp.cab"
            if (Test-Path $PackageFile) {
                Write-Host -ForegroundColor Gray "$PackageFile"
                $PackageName = "Add-WindowsPackage-WinPE-lp_$Lang"
                $CurrentLog = "$BuildMediaLogsPath\$((Get-Date).ToString('yyMMdd-HHmmss'))-$PackageName.log"
                try {
                    $WindowsImage | Add-WindowsPackage -PackagePath $PackageFile -LogPath "$CurrentLog" -ErrorAction Stop | Out-Null
                }
                catch {
                    if ($_.Exception.ErrorCode -eq '-2148468766') {
                        Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] 0x800f081e CBS_E_NOT_APPLICABLE The Windows ADK version you are using does not seem to support the WinPE version you are trying to service"
                    }
                    if ($_.Exception.ErrorCode -eq '-2146498512') {
                        Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] 0x800f0830 CBS_E_IMAGE_UNSERVICEABLE The specified image is no longer serviceable and may be corrupted. Discard the modified image and start again"
                    }
                }
            }
            else {
                Write-Host -ForegroundColor DarkGray "$PackageFile (not present)"
            }
            foreach ($Package in $WindowsAdkWinpePackages) {
                $PackageFile = "$WinPEOCs\$Lang\WinPE-$Package`_$Lang.cab"
                if (Test-Path $PackageFile) {
                    Write-Host -ForegroundColor Gray "$PackageFile"
                    $PackageName = "Add-WindowsPackage-WinPE-$Package`_$Lang"
                    $CurrentLog = "$BuildMediaLogsPath\$((Get-Date).ToString('yyMMdd-HHmmss'))-$PackageName.log"
                    try {
                        $WindowsImage | Add-WindowsPackage -PackagePath $PackageFile -LogPath "$CurrentLog" -ErrorAction Stop | Out-Null
                    }
                    catch {
                        if ($_.Exception.ErrorCode -eq '-2148468766') {
                            Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] 0x800f081e CBS_E_NOT_APPLICABLE The Windows ADK version you are using does not seem to support the WinPE version you are trying to service"
                        }
                        if ($_.Exception.ErrorCode -eq '-2146498512') {
                            Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] 0x800f0830 CBS_E_IMAGE_UNSERVICEABLE The specified image is no longer serviceable and may be corrupted. Discard the modified image and start again"
                        }
                    }
                }
                else {
                    Write-Host -ForegroundColor DarkGray "$PackageFile (not present)"
                }
            }
            # Generates a new Lang.ini file which is used to define the language packs inside the image
            if ( (Test-Path -Path "$MountPath\sources\lang.ini") ) {
                Write-Host -ForegroundColor DarkCyan "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Updating lang.ini"
                $CurrentLog = "$BuildMediaLogsPath\$((Get-Date).ToString('yyMMdd-HHmmss'))-Gen-LangINI.log"
                dism.exe /image:"$MountPath" /Gen-LangINI /distribution:"$MountPath" /LogPath:"$CurrentLog"
            }
            Step-BuildMediaWindowsImageSave
        }
        #endregion
    }
    #endregion
    #=================================================
    Step-BuildMediaDismSettings
    Step-BuildMediaAddWallpaper
    Step-BuildMediaPowerShellUpdate
    Step-WinPEAppAzCopy
    Step-WinPEAppWirelessConnect
    Step-WinPEAppZip
    Step-BuildMediaWinPEAppScript
    Step-BuildMediaWindowsImageSave
    Step-BuildMediaRemoveWinpeshl
    Step-BuildMediaConsoleSettings
    Step-BuildMediaWinPEScript
    Step-BuildMediaWinPEDriver
    Step-BuildMediaExportWindowsDriverPE
    Step-BuildMediaExportWindowsPackagePE
    Step-BuildMediaRegCurrentVersionExport
    Step-BuildMediaDismGetIntl
    Step-BuildMediaGetContentStartnet
    Step-BuildMediaGetContentWinpeshl
    Step-BuildMediaWindowsImageDismount
    Step-BuildMediaWindowsImageExport
    Step-BuildMediaWinPEMediaScript
    Step-BuildMediaIso
    Step-BuildMediaUpdateUSB
    #=================================================
    #region Complete
    # Add the final ADKPaths information to the bootmedia object
    $global:BuildMedia.AdkPaths = $WindowsAdkPaths

    # Add the final WinPE information to the bootmedia object
    $global:BuildMedia.PEInfo = $GetWindowsImage

    Write-Host -ForegroundColor DarkCyan "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Exporting BootMedia Profile to $BuildMediaCorePath\gv-buildprofile.json"
    $global:BuildProfile | Export-Clixml -Path "$BuildMediaCorePath\gv-buildprofile.xml" -Force
    $global:BuildProfile | ConvertTo-Json -Depth 5 -WarningAction SilentlyContinue | Out-File "$BuildMediaCorePath\gv-buildprofile.json" -Encoding utf8 -Force

    Write-Host -ForegroundColor DarkCyan "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Exporting BootMedia Properties to $BuildMediaCorePath\gv-buildmedia.json"
    $global:BuildMedia | Export-Clixml -Path "$BuildMediaCorePath\gv-buildmedia.xml" -Force
    $global:BuildMedia | ConvertTo-Json -Depth 5 -WarningAction SilentlyContinue | Out-File "$BuildMediaCorePath\gv-buildmedia.json" -Encoding utf8 -Force

    # Restore TLS settings
    [Net.ServicePointManager]::SecurityProtocol = $currentVersionTls
    $ProgressPreference = $currentProgressPref

    # Update BootMedia Index
    $null = Get-OSDWSWinPEBuild

    $buildEndTime = Get-Date
    $buildTimeSpan = New-TimeSpan -Start $BuildStartTime -End $buildEndTime
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] $($MyInvocation.MyCommand.Name) completed in $($buildTimeSpan.ToString("mm' minutes 'ss' seconds'"))"
    Stop-Transcript
    #endregion
    #=================================================
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}