function Get-OSDWorkspaceMediaWinPE {
    [CmdletBinding()]
    param (
        [ValidateSet('amd64', 'arm64')]
        [System.String]
        $Architecture
    )

    begin {
        #=================================================
        $Error.Clear()
        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
        #=================================================
        $OSWorkspaceBuildMediaPath = Get-OSDWorkspaceWinPEPath

        $BootMediaItems = @()
        $BootMediaItems = Get-ChildItem -Path $OSWorkspaceBuildMediaPath -Directory -ErrorAction SilentlyContinue | Select-Object -Property * | `
            Where-Object { Test-Path $(Join-Path $_.FullName 'WinPE-Media\sources\boot.wim') } | `
            Where-Object { Test-Path $(Join-Path $_.FullName '.core\id.json') } | `
            Where-Object { Test-Path $(Join-Path $_.FullName '.core\winos-windowsimage.xml') } | `
            Where-Object { Test-Path $(Join-Path $_.FullName '.core\winre-windowsimage.xml') } | `
            Where-Object { Test-Path $(Join-Path $_.FullName '.core\gv-buildmedia.xml') }

        $IndexXml = (Join-Path $OSWorkspaceBuildMediaPath 'index.xml')
        $IndexJson = (Join-Path $OSWorkspaceBuildMediaPath 'index.json')

        if ($BootMediaItems.Count -eq 0) {
            Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] OSDWorkspace WinPE Builds were not found"
            Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Run Build-OSDWorkspaceWinPE to resolve this issue"
            
            if (Test-Path $IndexXml) {
                Remove-Item -Path $IndexXml -Force -ErrorAction SilentlyContinue | Out-Null
            }
            if (Test-Path $IndexJson) {
                Remove-Item -Path $IndexJson -Force -ErrorAction SilentlyContinue | Out-Null
            }
            return
        }
    }
    process {
        $OSDWorkspaceBootMedia = foreach ($BootMediaItem in $BootMediaItems) {
            #=================================================
            #   Get-FullName
            #=================================================
            $BootMediaItemPath = $($BootMediaItem.FullName)
            #=================================================
            #   Import Details
            #=================================================
            $InfoId = "$BootMediaItemPath\.core\id.json"
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] InfoId: $InfoId"
            $ImportId = Get-Content $InfoId -Raw | ConvertFrom-Json
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Id: $($ImportId.Id)"

            $InfoOS = "$BootMediaItemPath\.core\winos-windowsimage.xml"
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] InfoOS: $InfoOS"
            $ClixmlOS = @()
            $ClixmlOS = Import-Clixml -Path $InfoOS

            $InfoREG = "$BootMediaItemPath\.core\winpe-regcurrentversion.xml"
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] InfoREG: $InfoREG"
            $ClixmlREG = @()
            $ClixmlREG = Import-Clixml -Path $InfoREG

            $InfoPE = "$BootMediaItemPath\.core\winpe-windowsimage.xml"
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] InfoPE: $InfoPE"
            $ClixmlPE = @()
            $ClixmlPE = Import-Clixml -Path $InfoPE

            $InfoRE = "$BootMediaItemPath\.core\winre-windowsimage.xml"
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] InfoRE: $InfoRE"
            $ClixmlRE = @()
            $ClixmlRE = Import-Clixml -Path $InfoRE

            $InfoBM = "$BootMediaItemPath\.core\gv-buildmedia.xml"
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] InfoBM: $InfoBM"
            $ClixmlBM = @()
            $ClixmlBM = Import-Clixml -Path $InfoBM
            #=================================================
            #   Resolve Architecture
            #=================================================
            $OSArchitecture = $ClixmlOS.Architecture
            if ($OSArchitecture -eq '0') { $OSArchitecture = 'x86' }
            if ($OSArchitecture -eq '1') { $OSArchitecture = 'MIPS' }
            if ($OSArchitecture -eq '2') { $OSArchitecture = 'Alpha' }
            if ($OSArchitecture -eq '3') { $OSArchitecture = 'PowerPC' }
            if ($OSArchitecture -eq '5') { $OSArchitecture = 'ARM' }
            if ($OSArchitecture -eq '6') { $OSArchitecture = 'ia64' }
            if ($OSArchitecture -eq '9') { $OSArchitecture = 'amd64' }
            if ($OSArchitecture -eq '12') { $OSArchitecture = 'arm64' }
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] OSArchitecture: $OSArchitecture"

            $OSEditionId = $($ClixmlOS.EditionId)
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] OSEditionId: $OSEditionId"

            $OSInstallationType = $($ClixmlOS.InstallationType)
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] OSInstallationType: $OSInstallationType"
            #=================================================
            #   WindowsImageWinRE
            #=================================================
            $WinREVersion = $($ClixmlRE.Version)
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] WinREVersion: $WinREVersion"

            $WinREMajorVersion = $($ClixmlRE.MajorVersion)
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] WinREMajorVersion: $WinREMajorVersion"

            $WinREMinorVersion = $($ClixmlRE.MinorVersion)
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] WinREMinorVersion: $WinREMinorVersion"

            $WinREBuild = $($ClixmlRE.Build)
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] WinREBuild: $WinREBuild"

            $WinRESPLevel = $($ClixmlRE.SPLevel)
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] WinRESPLevel: $WinRESPLevel"
            #=================================================
            #   Language
            #=================================================
            $WinRELanguages = $($ClixmlRE.Languages)
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Languages: $WinRELanguages"
            #=================================================
            #   Create Object
            #=================================================
            $ObjectProperties = [ordered]@{
                Type                 = 'WinPE'
                Id                   = $ImportId.Id
                Name                 = $ClixmlBM.Name
                ModifiedTime         = [datetime]$ClixmlPE.ModifiedTime
                InstallationType     = $ClixmlPE.InstallationType
                Version              = [System.String]"$($ClixmlPE.MajorVersion).$($ClixmlPE.MinorVersion).$($ClixmlPE.Build).$($ClixmlPE.SPBuild)"
                DisplayVersion       = $ClixmlREG.DisplayVersion
                ReleaseId            = $ClixmlREG.ReleaseId
                Architecture         = $OSArchitecture
                Languages            = $ClixmlPE.Languages
                SetAllIntl           = $ClixmlBM.SetAllIntl
                InputLocale          = $ClixmlBM.SetInputLocale
                TimeZone             = $ClixmlBM.SetTimeZone
                ContentStartnet      = $ClixmlBM.ContentStartnet
                ContentWinpeshl      = $ClixmlBM.ContentWinpeshl
                AddOnAzCopy          = $ClixmlBM.AddOnAzCopy
                AddOnMicrosoftDaRT   = $ClixmlBM.AddOnMicrosoftDaRT
                AddOnPwsh            = $ClixmlBM.AddOnPwsh
                AddOnWirelessConnect = $ClixmlBM.AddOnWirelessConnect
                AddOnZip             = $ClixmlBM.AddOnZip
                AdkVersion           = $ClixmlBM.AdkInstallVersion
                BuildProfile         = $ClixmlBM.BuildProfile
                LibraryWinPEDriver   = $ClixmlBM.LibraryWinPEDriver
                LibraryWinPEScript   = $ClixmlBM.LibraryWinPEScript
                LibraryMediaScript   = $ClixmlBM.LibraryMediaScript
                CreatedTime          = [datetime]$ClixmlPE.CreatedTime
                ImageName            = $ClixmlPE.ImageName
                ImagePath            = $BootMediaItemPath + '\Media\sources\boot.wim'
                ImageIndex           = [uint32]$ClixmlPE.ImageIndex
                ImageSize            = $ClixmlPE.ImageSize
                DirectoryCount       = $ClixmlPE.DirectoryCount
                FileCount            = $ClixmlPE.FileCount
                OSCreatedTime        = [datetime]$ClixmlOS.CreatedTime
                OSModifiedTime       = [datetime]$ClixmlOS.ModifiedTime
                OSImageName          = $ClixmlOS.ImageName
                OSEditionId          = $ClixmlOS.EditionId
                OSVersion            = [System.String]"$($ClixmlOS.MajorVersion).$($ClixmlOS.MinorVersion).$($ClixmlOS.Build).$($ClixmlOS.SPBuild)"
                Path                 = $BootMediaItemPath
            }
            New-Object -TypeName PSObject -Property $ObjectProperties
            $ObjectProperties | Export-Clixml -Path "$BootMediaItemPath\.core\object.xml" -Force
            $ObjectProperties | ConvertTo-Json -Depth 5 | Out-File -FilePath "$BootMediaItemPath\.core\object.json" -Encoding utf8 -Force
            $ObjectProperties | ConvertTo-Json -Depth 5 | Out-File -FilePath "$BootMediaItemPath\properties.json" -Encoding utf8 -Force
        }

        if ($OSDWorkspaceBootMedia) {
            # $OSDWorkspaceBootMedia | Export-Clixml -Path $IndexXml -Force
            $OSDWorkspaceBootMedia | ConvertTo-Json -Depth 5 | Out-File -FilePath $IndexJson -Encoding utf8 -Force

            if ($Architecture -eq 'amd64') {
                $OSDWorkspaceBootMedia = $OSDWorkspaceBootMedia | Where-Object { $_.Architecture -eq 'amd64' }
            }
            if ($Architecture -eq 'arm64') {
                $OSDWorkspaceBootMedia = $OSDWorkspaceBootMedia | Where-Object { $_.Architecture -eq 'arm64' }
            }
            if ($GridView) {
                $OSDWorkspaceBootMedia = $OSDWorkspaceBootMedia | Out-GridView -Title 'Select a BootMedia and press OK (Cancel to Exit)' -OutputMode $GridView
            }
            return $OSDWorkspaceBootMedia | Sort-Object -Property ModifiedTime -Descending
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