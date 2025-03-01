function Get-OSDWorkspaceBootMedia {
    [CmdletBinding()]
    param (
        [ValidateSet('amd64', 'arm64')]
        [System.String]
        $Architecture
    )

    begin {
        #=================================================
        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
        $Error.Clear()
        #=================================================
        $BootMediaItems = @()
        $BootMediaItems = Get-ChildItem -Path (Get-OSDWorkspaceBootMediaPath) -Directory -ErrorAction SilentlyContinue | Select-Object -Property * | `
            Where-Object { Test-Path $(Join-Path $_.FullName 'Media\sources\boot.wim') } | `
            Where-Object { Test-Path $(Join-Path $_.FullName 'core\gv-bootmedia.xml') } | `
            Where-Object { Test-Path $(Join-Path $_.FullName 'core\os-WindowsImage.xml') } | `
            Where-Object { Test-Path $(Join-Path $_.FullName 'core\winpe-WindowsImage.xml') }

        if ($BootMediaItems.Count -eq 0) {
            Write-Warning "$((Get-Date).ToString('yyMMdd-HHmmss')) OSDWorkspace BootMedia were not found"
            Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Run New-OSDWorkspaceBootMedia to resolve this issue"
            return
        }
    }
    process {
        $FrameworkBootMedia = foreach ($BootMediaItem in $BootMediaItems) {
            #=================================================
            #   Get-FullName
            #=================================================
            $BootMediaItemPath = $($BootMediaItem.FullName)
            #=================================================
            #   Import OS XML
            #=================================================
            $OSXML = @()
            $OSXML = Import-Clixml -Path "$BootMediaItemPath\core\os-WindowsImage.xml"
            #=================================================
            #   Import BootMedia XML
            #=================================================
            $BootMediaXML = @()
            $BootMediaXML = Import-Clixml -Path "$BootMediaItemPath\core\gv-bootmedia.xml"
            #=================================================
            #   WindowsImageOS
            #=================================================
            $OSImageName = $($OSXML.ImageName)
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] OSImageName: $OSImageName"

            $OSArchitecture = $OSXML.Architecture
            if ($OSArchitecture -eq '0') { $OSArchitecture = 'x86' }
            if ($OSArchitecture -eq '1') { $OSArchitecture = 'MIPS' }
            if ($OSArchitecture -eq '2') { $OSArchitecture = 'Alpha' }
            if ($OSArchitecture -eq '3') { $OSArchitecture = 'PowerPC' }
            if ($OSArchitecture -eq '5') { $OSArchitecture = 'ARM' }
            if ($OSArchitecture -eq '6') { $OSArchitecture = 'ia64' }
            if ($OSArchitecture -eq '9') { $OSArchitecture = 'amd64' }
            if ($OSArchitecture -eq '12') { $OSArchitecture = 'arm64' }
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] OSArchitecture: $OSArchitecture"

            $OSEditionId = $($OSXML.EditionId)
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] OSEditionId: $OSEditionId"

            $OSInstallationType = $($OSXML.InstallationType)
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] OSInstallationType: $OSInstallationType"
            #=================================================
            #   Import WinRE XML
            #=================================================
            $WinPEWindowsImage = @()
            $WinPEWindowsImage = Import-Clixml -Path "$BootMediaItemPath\core\winpe-WindowsImage.xml"
            #=================================================
            #   WindowsImageWinRE
            #=================================================
            $WinREVersion = $($WinPEWindowsImage.Version)
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] WinREVersion: $WinREVersion"

            $WinREMajorVersion = $($WinPEWindowsImage.MajorVersion)
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] WinREMajorVersion: $WinREMajorVersion"

            $WinREMinorVersion = $($WinPEWindowsImage.MinorVersion)
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] WinREMinorVersion: $WinREMinorVersion"

            $WinREBuild = $($WinPEWindowsImage.Build)
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] WinREBuild: $WinREBuild"

            $WinRESPLevel = $($WinPEWindowsImage.SPLevel)
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] WinRESPLevel: $WinRESPLevel"
            #=================================================
            #   Language
            #=================================================
            $WinRELanguages = $($WinPEWindowsImage.Languages)
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Languages: $WinRELanguages"
            #=================================================
            #   Create Object
            #=================================================
            $ObjectProperties = [ordered]@{
                Id                 = Split-Path -Leaf $BootMediaItemPath
                ModifiedTime       = [datetime]$WinPEWindowsImage.ModifiedTime
                Name               = $BootMediaXML.Name
                Version            = [version]$WinPEWindowsImage.Version
                Architecture       = $OSArchitecture
                WinpeshlContent    = $BootMediaXML.WinpeshlContent
                StartnetContent    = $BootMediaXML.StartnetContent
                Languages          = $WinPEWindowsImage.Languages
                SetInputLocale     = $BootMediaXML.SetInputLocale
                SetAllIntl         = $BootMediaXML.SetAllIntl
                TimeZone           = $BootMediaXML.TimeZone
                AddAzCopy          = $BootMediaXML.AddAzCopy
                AddMicrosoftDaRT   = $BootMediaXML.AddMicrosoftDaRT
                AddPwsh            = $BootMediaXML.AddPwsh
                AddWirelessConnect = $BootMediaXML.AddWirelessConnect
                AddZip             = $BootMediaXML.AddZip
                BootDriver         = $BootMediaXML.BootDriver
                AdkVersion         = $BootMediaXML.AdkInstallVersion
                OSCreatedTime      = [datetime]$OSXML.CreatedTime
                OSEditionId        = $OSXML.EditionId
                OSImageName        = $OSXML.ImageName
                OSVersion          = [version]$OSXML.Version
                CreatedTime        = [datetime]$WinPEWindowsImage.CreatedTime
                InstallationType   = $WinPEWindowsImage.InstallationType
                Path               = $BootMediaItemPath
                ImagePath          = $BootMediaItemPath + '\Media\sources\boot.wim'
                ImageIndex         = $WinPEWindowsImage.ImageIndex
                ImageName          = $WinPEWindowsImage.ImageName
                ImageSize          = $WinPEWindowsImage.ImageSize
                DirectoryCount     = $WinPEWindowsImage.DirectoryCount
                FileCount          = $WinPEWindowsImage.FileCount
            }
            New-Object -TypeName PSObject -Property $ObjectProperties
            if (!(Test-Path -Path "$BootMediaItemPath\BootMedia.json")) {
                $ObjectProperties | ConvertTo-Json | Out-File -FilePath "$BootMediaItemPath\BootMedia.json" -Encoding utf8 -Force
            }
        }

        if ($FrameworkBootMedia) {
            if ($Architecture -eq 'amd64') {
                $FrameworkBootMedia = $FrameworkBootMedia | Where-Object { $_.Architecture -eq 'amd64' }
            }
            if ($Architecture -eq 'arm64') {
                $FrameworkBootMedia = $FrameworkBootMedia | Where-Object { $_.Architecture -eq 'arm64' }
            }
            if ($GridView) {
                $FrameworkBootMedia = $FrameworkBootMedia | Out-GridView -Title 'Select a BootMedia and press OK (Cancel to Exit)' -OutputMode $GridView
            }
            return $FrameworkBootMedia | Sort-Object -Property Id
        }
        else {
            return $null
        }
        #=================================================
    }
    end {
        #=================================================
        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
        #=================================================
    }
}