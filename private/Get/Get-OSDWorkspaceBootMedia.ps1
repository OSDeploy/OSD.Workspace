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
            Where-Object { Test-Path $(Join-Path $_.FullName 'bin\bootmedia.xml') } | `
            Where-Object { Test-Path $(Join-Path $_.FullName 'bin\os.xml') } | `
            Where-Object { Test-Path $(Join-Path $_.FullName 'bin\pe.xml') }

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
            $OSXML = Import-Clixml -Path "$BootMediaItemPath\bin\os.xml"
            #=================================================
            #   Import BootMedia XML
            #=================================================
            $BootMediaXML = @()
            $BootMediaXML = Import-Clixml -Path "$BootMediaItemPath\bin\bootmedia.xml"
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
            $WindowsImageWinRE = @()
            $WindowsImageWinRE = Import-Clixml -Path "$BootMediaItemPath\bin\pe.xml"
            #=================================================
            #   WindowsImageWinRE
            #=================================================
            $WinREVersion = $($WindowsImageWinRE.Version)
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] WinREVersion: $WinREVersion"

            $WinREMajorVersion = $($WindowsImageWinRE.MajorVersion)
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] WinREMajorVersion: $WinREMajorVersion"

            $WinREMinorVersion = $($WindowsImageWinRE.MinorVersion)
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] WinREMinorVersion: $WinREMinorVersion"

            $WinREBuild = $($WindowsImageWinRE.Build)
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] WinREBuild: $WinREBuild"

            $WinRESPLevel = $($WindowsImageWinRE.SPLevel)
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] WinRESPLevel: $WinRESPLevel"
            #=================================================
            #   Language
            #=================================================
            $WinRELanguages = $($WindowsImageWinRE.Languages)
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Languages: $WinRELanguages"
            #=================================================
            #   Create Object
            #=================================================
            $ObjectProperties = [ordered]@{
                Id                 = Split-Path -Leaf $BootMediaItemPath
                ModifiedTime       = [datetime]$WindowsImageWinRE.ModifiedTime
                Name               = $BootMediaXML.Name
                Version            = [version]$WindowsImageWinRE.Version
                Architecture       = $OSArchitecture
                WinpeshlContent    = $BootMediaXML.WinpeshlContent
                StartnetContent    = $BootMediaXML.StartnetContent
                Languages          = $WindowsImageWinRE.Languages
                SetInputLocale     = $BootMediaXML.SetInputLocale
                SetAllIntl         = $BootMediaXML.SetAllIntl
                TimeZone           = $BootMediaXML.TimeZone
                AddAzCopy          = $BootMediaXML.AddAzCopy
                AddMicrosoftDaRT   = $BootMediaXML.AddMicrosoftDaRT
                AddPowerShell      = $BootMediaXML.AddPowerShell
                AddWirelessConnect = $BootMediaXML.AddWirelessConnect
                AddZip             = $BootMediaXML.AddZip
                BootDriver         = $BootMediaXML.BootDriver
                AdkVersion         = $BootMediaXML.AdkInstallVersion
                OSCreatedTime      = [datetime]$OSXML.CreatedTime
                OSEditionId        = $OSXML.EditionId
                OSImageName        = $OSXML.ImageName
                OSVersion          = [version]$OSXML.Version
                CreatedTime        = [datetime]$WindowsImageWinRE.CreatedTime
                InstallationType   = $WindowsImageWinRE.InstallationType
                Path               = $BootMediaItemPath
                ImagePath          = $BootMediaItemPath + '\winre.wim'
                ImageIndex         = $WindowsImageWinRE.ImageIndex
                ImageName          = $WindowsImageWinRE.ImageName
                ImageSize          = $WindowsImageWinRE.ImageSize
                DirectoryCount     = $WindowsImageWinRE.DirectoryCount
                FileCount          = $WindowsImageWinRE.FileCount
            }
            New-Object -TypeName PSObject -Property $ObjectProperties
            Write-Verbose ''
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