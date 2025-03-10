function Import-OSDWorkspaceWinOS {
    <#
    .SYNOPSIS
        Imports the winre.wim from a mounted Windows Installation Media ISO to the OSDWorkspace BootImage directory.

    .DESCRIPTION
        Imports the winre.wim from a mounted Windows Installation Media ISO to the OSDWorkspace BootImage directory.
        Supports both Windows 11 24H2 amd64 and arm64 Windows Installation Media ISO.
        Will display a Out-GridView of the available Indexes for each Mounted Windows Installation Media ISO.
        Select one or multiple Indexes to import.
        The BootImage will be imported to the OSDWorkspace BootImage directory with a name of the format "yyMMdd-HHmm Architecture".

    .EXAMPLE
        Import-OSDWorkspaceWinOS
        Imports the winre.wim from a mounted Windows Installation Media ISO to the OSDWorkspace BootImage directory.

    .INPUTS
        None.

        You cannot pipe input to this cmdlet.

    .OUTPUTS
        None.

        This function does not return any output.

    .LINK
        https://github.com/OSDeploy/OSD.Workspace/blob/main/docs/Import-OSDWorkspaceWinOS.md

    .NOTES
        David Segura
    #>
    [CmdletBinding()]
    param ()

    begin {
        #=================================================
        $Error.Clear()
        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
        #=================================================
        # Requires Run as Administrator
        $IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        if (-not $IsAdmin ) {
            Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] This function must be Run as Administrator"
            return
        }
        #=================================================
        $WindowsMediaImages = @()
        $WindowsMediaImages = Get-PSDriveWindowsImageIndex -GridView Multiple
        #=================================================
    }
    process {
        #=================================================
        #region InputObject
        if ($null -eq $WindowsMediaImages) {
            Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] WindowsImage on Windows Installation Media was not found. Mount a Windows Installation ISO and try again."
            Write-Host "Windows 11 x64 Download: https://www.microsoft.com/en-us/software-download/windows11"
            Write-Host "Windows 11 arm64 Download https://www.microsoft.com/en-us/software-download/windows11arm64"
            return
        }
        #endregion
        #=================================================
        #region Process foreach WindowsImage
        foreach ($SourceWindowsImage in $WindowsMediaImages) {
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] foreach"

            # Set the BuildDateTime
            $BuildDateTime = $((Get-Date).ToString('yyMMdd-HHmm'))
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] BuildDateTime: $BuildDateTime"

            # Set the Architecture
            $Architecture = $SourceWindowsImage.Architecture
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Architecture: $Architecture"

            # Set the Destination Name
            $DestinationName = "$($BuildDateTime)-$($Architecture)"
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] DestinationName: $DestinationName"
            
            # Set the Destination Path
            $DestinationDirectory = Join-Path $(Get-OSDWSWinOSSourcePath) "$DestinationName"
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] DestinationDirectory: $DestinationDirectory"
            
            # Set the Recovery Image Path
            $ImportWinREDirectory = Join-Path $(Get-OSDWSWinRESourcePath) "$DestinationName"
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] ImageREDirectory: $ImportWinREDirectory"

            $DestinationCore = "$DestinationDirectory\.core"
            $DestinationTemp = "$DestinationDirectory\.temp"
            $DestinationLogs = "$DestinationTemp\logs"
            $DestinationWim = "$DestinationDirectory\.wim"
            $DestinationMedia = "$DestinationDirectory\WinOS-Media"

            New-Item -Path $DestinationCore -ItemType Directory -Force -ErrorAction Stop | Out-Null
            New-Item -Path $DestinationLogs -ItemType Directory -Force -ErrorAction Stop | Out-Null
            New-Item -Path $DestinationWim -ItemType Directory -Force -ErrorAction Stop | Out-Null
            New-Item -Path $DestinationMedia -ItemType Directory -Force -ErrorAction Stop | Out-Null

            $ImportId = @{id = $DestinationName }
            $ImportId | ConvertTo-Json -Depth 5 | Out-File "$DestinationCore\id.json" -Encoding utf8 -Force

            robocopy "$($SourceWindowsImage.MediaRoot)" "$DestinationMedia" *.* /e /xf install.wim install.esd | Out-Null
            Get-ChildItem -Recurse -Path "$DestinationMedia\*" | Set-ItemProperty -Name IsReadOnly -Value $false -ErrorAction SilentlyContinue | Out-Null

            $DestinationImagePath = "$DestinationMedia\sources\install.wim"
            $CurrentLog = "$DestinationLogs\$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-Export-windowsimage.log"
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] CurrentLog: $CurrentLog"
            Export-WindowsImage -SourceImagePath $($SourceWindowsImage.ImagePath) -SourceIndex $($SourceWindowsImage.ImageIndex) -DestinationImagePath $DestinationImagePath -LogPath "$CurrentLog" | Out-Null
            
            # Export the Operating System information
            $Image = Get-WindowsImage -ImagePath $DestinationImagePath -Index 1

            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Export $DestinationCore\winos-windowsimage.xml"
            $Image | Export-Clixml -Path "$DestinationCore\winos-windowsimage.xml"
            
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Export $DestinationCore\winos-windowsimage.json"
            $Image | ConvertTo-Json -Depth 5 | Out-File "$DestinationCore\winos-windowsimage.json" -Encoding utf8

            # Mount the Windows Image and store the details
            $MountedWindows = Mount-MyWindowsImage -ImagePath $DestinationImagePath -Index 1 -ErrorAction Stop -ReadOnly
            $MountDirectory = $MountedWindows.Path

            # Backup WinRE
            Copy-Item -Path "$MountDirectory\Windows\System32\Recovery\ReAgent.xml" -Destination "$DestinationDirectory\.temp\os-reagent.xml" | Out-Null
            Copy-Item -Path "$MountDirectory\Windows\System32\Recovery\winre.wim" -Destination "$DestinationWim\winre.wim" | Out-Null

            $WinreImage = Get-WindowsImage -ImagePath "$DestinationWim\winre.wim" -Index 1
            $WinreImage | ConvertTo-Json -Depth 5 | Out-File "$DestinationCore\winre-windowsimage.json" -Encoding utf8 -Force
            $WinreImage | Export-Clixml -Path "$DestinationCore\winre-windowsimage.xml"

            # Export WinSE and WinPE
            $BootWim = "$($SourceWindowsImage.MediaRoot)sources\boot.wim"
            if (Test-Path $BootWim) {
                $CurrentLog = "$DestinationLogs\$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-Export-WinSE.log"
                $ExportWinSE = Export-WindowsImage -SourceImagePath $BootWim -SourceIndex 1 -DestinationImagePath "$DestinationWim\winse.wim" -LogPath "$CurrentLog" | Out-Null
                $WinseImage = Get-WindowsImage -ImagePath "$DestinationWim\winse.wim" -Index 1
                $WinseImage | ConvertTo-Json -Depth 5 | Out-File "$DestinationCore\winse-windowsimage.json" -Encoding utf8 -Force
                $WinseImage | Export-Clixml -Path "$DestinationCore\winse-windowsimage.xml"


                $CurrentLog = "$DestinationLogs\$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-Export-WinPE.log"
                $ExportWinPE = Export-WindowsImage -SourceImagePath $BootWim -SourceIndex 2 -DestinationImagePath "$DestinationWim\winpe.wim" -LogPath "$CurrentLog" | Out-Null
                $WinpeImage = Get-WindowsImage -ImagePath "$DestinationWim\winpe.wim" -Index 1
                $WinpeImage | ConvertTo-Json -Depth 5 | Out-File "$DestinationCore\winpe-windowsimage.json" -Encoding utf8 -Force
                $WinpeImage | Export-Clixml -Path "$DestinationCore\winpe-windowsimage.xml"
            }

            # Backup OSFiles
            #=================================================
            #region RegistryHives
            $BackupOSFiles = @(
                'SOFTWARE'
                'SYSTEM'
            )
            $RobocopyLog = "$DestinationLogs\os-registry.log"
            foreach ($Item in $BackupOSFiles) {
                robocopy "$MountDirectory\Windows\System32\config" "$DestinationDirectory\.temp" $Item /b /np /ts /tee /r:0 /w:0 /log+:"$RobocopyLog" | Out-Null
            }
            $RenameItem = Rename-Item -Path "$DestinationDirectory\.temp\SOFTWARE" -NewName 'os-software.hive' -Force -ErrorAction SilentlyContinue
            $RenameItem = Rename-Item -Path "$DestinationDirectory\.temp\SYSTEM" -NewName 'os-system.hive' -Force -ErrorAction SilentlyContinue
            #endregion
            #=================================================
            #region Boot
            $RobocopyLog = "$DestinationLogs\os-boot.log"
            if (Test-Path "$MountDirectory\Windows") {
                robocopy "$MountDirectory\Windows\Boot" "$DestinationCore\os-boot" *.* /e /tee /r:0 /w:0 /log+:"$RobocopyLog" | Out-Null
            }
            #endregion
            #=================================================
            #region WindowsExecutables and Subdirectories
            $BackupOSFiles = @(
                'aerolite*.*' # AeroLite Theme
                'bcp47*.dll' # BCP47
                'bits*.*' # 2Pint OSD Toolkit
                'BitsTransfer*.*' # 2Pint OSD Toolkit
                'BranchCache*.*' # 2Pint OSD Toolkit
                'cacls.exe*'
                'choice.exe*'
                'comp.exe*.*'
                'credssp*.*' # 2Pint OSD Toolkit
                'curl.exe'
                'ddp*.*' # 2Pint OSD Toolkit
                'defrag.exe*'
                'djoin*.*'
                'dmcmnutils*.*' # Wireless
                'dssec*.*' # 2Pint OSD Toolkit
                'dsuiext*.*' # 2Pint OSD Toolkit
                'edputil*.*' # Browse Dialog
                'es.dll*' # 2Pint OSD Toolkit
                'explorerframe*.*' # Browse Dialog
                'forfiles*.*'
                'getmac*.*'
                'gpedit*.*' # 2Pint OSD Toolkit
                'hyyp.sys*' # 2Pint OSD Toolkit
                'magnification*.*'
                'magnify*.*'
                'makecab.*'
                'mdmpostprocessevaluator*.*' # Wireless
                'mdmregistration*.*' # Wireless
                'mscms*.*' # On Screen Keyboard
                'msinfo32.*'
                'mstsc*.*' # RDP
                'netprofm*.*' # 2Pint OSD Toolkit
                'npmproxy*.*' # 2Pint OSD Toolkit
                'nslookup.*'
                'osk*.*' # On Screen Keyboard
                'pdh.dll*' # RDP
                'PeerDist*.*' # 2Pint OSD Toolkit
                'perfmon*.*'
                'setx.*'
                'shellstyle*.*' # AeroLite Theme
                'shutdown.*'
                'shutdownext.*'
                'shutdownux.*'
                'srpapi.dll*' # RDP
                'ssdpapi*.*' # 2Pint OSD Toolkit
                'StructuredQuery*.*' # Browse Dialog
                'systeminfo.*'
                'tar.exe'
                'tskill.*'
                'winver.*'
                'WSDApi*.*' # 2Pint OSD Toolkit
            )
            $RobocopyLog = "$DestinationLogs\os-files.log"
            foreach ($Item in $BackupOSFiles) {
                robocopy "$MountDirectory\Windows\System32" "$DestinationCore\os-files\Windows\System32" $Item /s /xd rescache servicing /ndl /b /np /ts /tee /r:0 /w:0 /log+:"$RobocopyLog" | Out-Null
            }
            #endregion
            #=================================================
            #region Dismount the Windows Image
            Dismount-WindowsImage -Path $MountDirectory -Discard | Out-Null
            
            # Remove Read-Only from all files
            Get-ChildItem -Path $DestinationDirectory -File -Recurse -Force | ForEach-Object {
                Set-ItemProperty -Path $_.FullName -Name IsReadOnly -Value $false -Force -ErrorAction Ignore | Out-Null
            }

            # Build the WinRE directory
            robocopy "$DestinationDirectory\.core" "$ImportWinREDirectory\.core" *.* /e /xf OSImage.* winpe-windowsimage* winse-windowsimage* /tee /r:0 /w:0 | Out-Null
            robocopy "$DestinationDirectory\.temp" "$ImportWinREDirectory\.temp" *.* /e /xd logs /tee /r:0 /w:0 | Out-Null
            robocopy "$DestinationDirectory\.wim" "$ImportWinREDirectory\.wim" winre.wim /e /tee /r:0 /w:0 | Out-Null

            # Update the Index
            $null = Get-OSDWSWinOSSource
            $null = Get-OSDWSWinRESource

            Get-Item -Path $DestinationDirectory
            #endregion
            #=================================================
        }
        #endregion
        #=================================================
    }
    end {
        #=================================================
        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
        #=================================================
    }
}