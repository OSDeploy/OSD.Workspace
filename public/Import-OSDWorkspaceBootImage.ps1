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
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] [`$SourceDirectory] <-- [$SourceDirectory]"

            $SourceImagePath = $WindowsImageFile.FullName
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] [`$SourceImagePath] <-- [$SourceImagePath]"

            # Get the Source Details
            $SourceWindowsImage = Import-Clixml -Path "$SourceDirectory\os.xml"

            # Set Architecture to human readable
            if ($SourceWindowsImage.Architecture -eq '0') { $Architecture = 'x86' }
            if ($SourceWindowsImage.Architecture -eq '1') { $Architecture = 'MIPS' }
            if ($SourceWindowsImage.Architecture -eq '2') { $Architecture = 'Alpha' }
            if ($SourceWindowsImage.Architecture -eq '3') { $Architecture = 'PowerPC' }
            if ($SourceWindowsImage.Architecture -eq '5') { $Architecture = 'ARM' }
            if ($SourceWindowsImage.Architecture -eq '6') { $Architecture = 'ia64' }
            if ($SourceWindowsImage.Architecture -eq '9') { $Architecture = 'amd64' }
            if ($SourceWindowsImage.Architecture -eq '12') { $Architecture = 'arm64' }
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] [`$Architecture] <-- [$Architecture]"

            # Set the Destination
            $DestinationName = "$BuildDateTime $Architecture"
            
            $DestinationDirectory = Join-Path $(Get-OSDWorkspaceBootImagePath) "$DestinationName"
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] [`$DestinationDirectory] <-- [$DestinationDirectory]"

            New-Item -Path "$DestinationDirectory\bin" -ItemType Directory -Force -ErrorAction Stop | Out-Null

            # Copy the OS details
            Copy-Item -Path "$SourceDirectory\os.xml" -Destination "$DestinationDirectory\bin"
            Copy-Item -Path "$SourceDirectory\os.json" -Destination "$DestinationDirectory\bin"

            # Copy the WinPE details
            #Copy-Item -Path "$SourceDirectory\winpe.wim" -Destination $DestinationDirectory
            #Copy-Item -Path "$SourceDirectory\pe.xml" -Destination "$DestinationDirectory\bin"
            #Copy-Item -Path "$SourceDirectory\pe.json" -Destination "$DestinationDirectory\bin"

            # Mount the Windows Image and store the details
            $MountedWindows = Mount-MyWindowsImage -ImagePath $SourceImagePath -Index 1 -ErrorAction Stop -ReadOnly
            $MountDirectory = $MountedWindows.Path

            # Backup WinRE
            # Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] [$MountDirectory\Windows\System32\Recovery\winre.wim] --> [$DestinationDirectory]"
            Copy-Item -Path "$MountDirectory\Windows\System32\Recovery\winre.wim" -Destination $DestinationDirectory

            # Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] [$MountDirectory\Windows\System32\Recovery\ReAgent.xml] --> [$DestinationDirectory\bin]"
            Copy-Item -Path "$MountDirectory\Windows\System32\Recovery\ReAgent.xml" -Destination "$DestinationDirectory\bin"

            Get-WindowsImage -ImagePath "$DestinationDirectory\winre.wim" -Index 1 | ConvertTo-Json | Out-File "$DestinationDirectory\bin\pe.json" -Encoding utf8
            Get-WindowsImage -ImagePath "$DestinationDirectory\winre.wim" -Index 1 | Export-Clixml -Path "$DestinationDirectory\bin\pe.xml"

            # Backup OSFiles
            $OSFilesLog = "$DestinationDirectory\bin\osfiles.log"
            #=================================================
            #region RegistryHives
            $BackupOSFiles = @(
                'SOFTWARE'
                'SYSTEM'
            )
            foreach ($Item in $BackupOSFiles) {
                # Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] [$MountDirectory\Windows\System32\config\$Item] --> [$DestinationDirectory\bin]"
                robocopy "$MountDirectory\Windows\System32\config" "$DestinationDirectory\bin" $Item /b /np /ts /tee /r:0 /w:0 /log+:"$OSFilesLog" | Out-Null
            }
            #endregion
            #=================================================
            #region Boot
            if (Test-Path "$MountDirectory\Windows") {
                # Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] [$MountDirectory\Windows\Boot] --> [$DestinationDirectory\bin\boot]"
                robocopy "$MountDirectory\Windows\Boot" "$DestinationDirectory\bin\boot" *.* /e /tee /r:0 /w:0 /log+:"$OSFilesLog" | Out-Null
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
                # Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] [$MountDirectory\Windows\System32\$Item] --> [$DestinationDirectory\bin\osfiles\Windows\System32]"
                robocopy "$MountDirectory\Windows\System32" "$DestinationDirectory\bin\osfiles\Windows\System32" $Item /s /xd rescache servicing /ndl /b /np /ts /tee /r:0 /w:0 /log+:"$OSFilesLog" | Out-Null
            }
            #endregion
            #=================================================
            #region Dismount the Windows Image
            # Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Dismounting WindowsImage"
            Dismount-WindowsImage -Path $MountDirectory -Discard

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