function Get-OSDWSWinPEBuild {
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
        $BuildPath = $OSDWorkspace.paths.build_windows_pe
        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] BuildPath: $BuildPath"

        $BuildItems = @()
        $BuildItems = Get-ChildItem -Path $BuildPath -Directory -ErrorAction SilentlyContinue | Select-Object -Property * | `
            Where-Object { Test-Path $(Join-Path $_.FullName 'WinPE-Media\sources\boot.wim') } | `
            Where-Object { Test-Path $(Join-Path $_.FullName '.core\id.json') } | `
            Where-Object { Test-Path $(Join-Path $_.FullName '.core\winos-windowsimage.xml') } | `
            Where-Object { Test-Path $(Join-Path $_.FullName '.core\winre-windowsimage.xml') } | `
            Where-Object { Test-Path $(Join-Path $_.FullName '.core\gv-buildmedia.xml') }

        $IndexXml = (Join-Path $BuildPath 'index.xml')
        $IndexJson = (Join-Path $BuildPath 'index.json')

        if ($BuildItems.Count -eq 0) {
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
        $WinPEBuilds = foreach ($BuildItem in $BuildItems) {
            #=================================================
            #   Get-FullName
            #=================================================
            $BuildItemPath = $($BuildItem.FullName)
            #=================================================
            #   Import Details
            #=================================================
            $InfoId = "$BuildItemPath\.core\id.json"
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] InfoId: $InfoId"
            $ImportId = Get-Content $InfoId -Raw | ConvertFrom-Json
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Id: $($ImportId.Id)"

            $InfoOS = "$BuildItemPath\.core\winos-windowsimage.xml"
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] InfoOS: $InfoOS"
            $ClixmlOS = @()
            $ClixmlOS = Import-Clixml -Path $InfoOS

            $InfoREG = "$BuildItemPath\.core\winpe-regcurrentversion.xml"
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] InfoREG: $InfoREG"
            $ClixmlREG = @()
            $ClixmlREG = Import-Clixml -Path $InfoREG

            $InfoPE = "$BuildItemPath\.core\winpe-windowsimage.xml"
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] InfoPE: $InfoPE"
            $ClixmlPE = @()
            $ClixmlPE = Import-Clixml -Path $InfoPE

            $InfoRE = "$BuildItemPath\.core\winre-windowsimage.xml"
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] InfoRE: $InfoRE"
            $ClixmlRE = @()
            $ClixmlRE = Import-Clixml -Path $InfoRE

            $InfoBM = "$BuildItemPath\.core\gv-buildmedia.xml"
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
                ImagePath            = $BuildItemPath + '\Media\sources\boot.wim'
                ImageIndex           = [uint32]$ClixmlPE.ImageIndex
                ImageSize            = $ClixmlPE.ImageSize
                DirectoryCount       = $ClixmlPE.DirectoryCount
                FileCount            = $ClixmlPE.FileCount
                OSCreatedTime        = [datetime]$ClixmlOS.CreatedTime
                OSModifiedTime       = [datetime]$ClixmlOS.ModifiedTime
                OSImageName          = $ClixmlOS.ImageName
                OSEditionId          = $ClixmlOS.EditionId
                OSVersion            = [System.String]"$($ClixmlOS.MajorVersion).$($ClixmlOS.MinorVersion).$($ClixmlOS.Build).$($ClixmlOS.SPBuild)"
                Path                 = $BuildItemPath
            }
            New-Object -TypeName PSObject -Property $ObjectProperties
            $ObjectProperties | Export-Clixml -Path "$BuildItemPath\.core\object.xml" -Force
            $ObjectProperties | ConvertTo-Json -Depth 5 | Out-File -FilePath "$BuildItemPath\.core\object.json" -Encoding utf8 -Force
            $ObjectProperties | ConvertTo-Json -Depth 5 | Out-File -FilePath "$BuildItemPath\properties.json" -Encoding utf8 -Force
        }

        if ($WinPEBuilds) {
            # $WinPEBuilds | Export-Clixml -Path $IndexXml -Force
            $WinPEBuilds | ConvertTo-Json -Depth 5 | Out-File -FilePath $IndexJson -Encoding utf8 -Force

            if ($Architecture -eq 'amd64') {
                $WinPEBuilds = $WinPEBuilds | Where-Object { $_.Architecture -eq 'amd64' }
            }
            if ($Architecture -eq 'arm64') {
                $WinPEBuilds = $WinPEBuilds | Where-Object { $_.Architecture -eq 'arm64' }
            }
            if ($GridView) {
                $WinPEBuilds = $WinPEBuilds | Out-GridView -Title 'Select a BootMedia and press OK (Cancel to Exit)' -OutputMode $GridView
            }
            return $WinPEBuilds | Sort-Object -Property ModifiedTime -Descending
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