function Import-OSDWorkspaceBootImage {
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
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Gathering mounted WindowsImage information"
        $OSWindowsImageFile = Export-PSDriveWindowsImageIndex
        #=================================================
    }
    process {
        #=================================================
        #region InputObject
        if ($null -eq $OSWindowsImageFile) {
            Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] WindowsImage on Windows Installation Media was not found. Mount a Windows Installation ISO and try again."
            Write-Host "Windows 11 x64 Download: https://www.microsoft.com/en-us/software-download/windows11"
            Write-Host "Windows 11 arm64 Download https://www.microsoft.com/en-us/software-download/windows11arm64"
            return
        }
        #endregion
        #=================================================
        #region Process foreach WindowsImage
        foreach ($WindowsImageFile in $OSWindowsImageFile) {
            # Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Processing WindowsImage"
            # Set the BuildDateTime
            $BuildDateTime = $((Get-Date).ToString('yyMMdd-HHmmss'))

            # Set the Source
            $SourceDirectory = $WindowsImageFile.Directory
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] SourceDirectory: $SourceDirectory"

            $SourceImagePath = $WindowsImageFile.FullName
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] SourceImagePath: $SourceImagePath"

            # Get the Source Details
            $SourceWindowsImage = Import-Clixml -Path "$SourceDirectory\os-WindowsImage.xml"

            # Set Architecture to human readable
            if ($SourceWindowsImage.Architecture -eq '0') { $Architecture = 'x86' }
            if ($SourceWindowsImage.Architecture -eq '1') { $Architecture = 'MIPS' }
            if ($SourceWindowsImage.Architecture -eq '2') { $Architecture = 'Alpha' }
            if ($SourceWindowsImage.Architecture -eq '3') { $Architecture = 'PowerPC' }
            if ($SourceWindowsImage.Architecture -eq '5') { $Architecture = 'ARM' }
            if ($SourceWindowsImage.Architecture -eq '6') { $Architecture = 'ia64' }
            if ($SourceWindowsImage.Architecture -eq '9') { $Architecture = 'amd64' }
            if ($SourceWindowsImage.Architecture -eq '12') { $Architecture = 'arm64' }
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Architecture: $Architecture]"

            # Set the Destination
            $DestinationName = "$BuildDateTime $Architecture"
            
            $DestinationDirectory = Join-Path $(Get-OSDWorkspaceBootImagePath) "$DestinationName"
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] DestinationDirectory: $DestinationDirectory"

            New-Item -Path "$DestinationDirectory\core" -ItemType Directory -Force -ErrorAction Stop | Out-Null
            New-Item -Path "$DestinationDirectory\sources" -ItemType Directory -Force -ErrorAction Stop | Out-Null
            New-Item -Path "$DestinationDirectory\temp" -ItemType Directory -Force -ErrorAction Stop | Out-Null

            # Copy the OS details
            Copy-Item -Path "$SourceDirectory\os-WindowsImage.xml" -Destination "$DestinationDirectory\core"
            Copy-Item -Path "$SourceDirectory\os-WindowsImage.json" -Destination "$DestinationDirectory\core"

            # Copy the WinPE details
            #Copy-Item -Path "$SourceDirectory\winpe.wim" -Destination $DestinationDirectory
            #Copy-Item -Path "$SourceDirectory\winpe-WindowsImage.xml" -Destination "$DestinationDirectory\core"
            #Copy-Item -Path "$SourceDirectory\winpe-WindowsImage.json" -Destination "$DestinationDirectory\core"

            # Mount the Windows Image and store the details
            $MountedWindows = Mount-MyWindowsImage -ImagePath $SourceImagePath -Index 1 -ErrorAction Stop -ReadOnly
            $MountDirectory = $MountedWindows.Path

            # Backup WinRE
            Copy-Item -Path "$MountDirectory\Windows\System32\Recovery\ReAgent.xml" -Destination "$DestinationDirectory\temp\os-reagent.xml"
            Copy-Item -Path "$MountDirectory\Windows\System32\Recovery\winre.wim" -Destination "$DestinationDirectory\sources\boot.wim"

            $WinreImage = Get-WindowsImage -ImagePath "$DestinationDirectory\sources\boot.wim" -Index 1
            $WinreImage | ConvertTo-Json | Out-File "$DestinationDirectory\core\winpe-WindowsImage.json" -Encoding utf8
            $WinreImage | Export-Clixml -Path "$DestinationDirectory\core\winpe-WindowsImage.xml"

            # Backup OSFiles
            $RobocopyLog = "$DestinationDirectory\temp\robocopy.log"
            #=================================================
            #region RegistryHives
            $BackupOSFiles = @(
                'SOFTWARE'
                'SYSTEM'
            )
            foreach ($Item in $BackupOSFiles) {
                robocopy "$MountDirectory\Windows\System32\config" "$DestinationDirectory\temp" $Item /b /np /ts /tee /r:0 /w:0 /log+:"$RobocopyLog" | Out-Null
            }
            $RenameItem = Rename-Item -Path "$DestinationDirectory\temp\SOFTWARE" -NewName 'os-software.hive' -Force -ErrorAction SilentlyContinue
            $RenameItem = Rename-Item -Path "$DestinationDirectory\temp\SYSTEM" -NewName 'os-system.hive' -Force -ErrorAction SilentlyContinue
            #endregion
            #=================================================
            #region Boot
            if (Test-Path "$MountDirectory\Windows") {
                robocopy "$MountDirectory\Windows\Boot" "$DestinationDirectory\core\os-boot" *.* /e /tee /r:0 /w:0 /log+:"$RobocopyLog" | Out-Null
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
            foreach ($Item in $BackupOSFiles) {
                robocopy "$MountDirectory\Windows\System32" "$DestinationDirectory\core\os-files\Windows\System32" $Item /s /xd rescache servicing /ndl /b /np /ts /tee /r:0 /w:0 /log+:"$RobocopyLog" | Out-Null
            }
            #endregion
            #=================================================
            #region Dismount the Windows Image
            Dismount-WindowsImage -Path $MountDirectory -Discard

            $null = Get-OSDWorkspaceBootImage

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