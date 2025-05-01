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
        Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Start"
        #=================================================
        $BuildPath = $OSDWorkspace.paths.build_windows_pe
        Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] BuildPath: $BuildPath"

        $BuildItems = @()
        $BuildItems = Get-ChildItem -Path $BuildPath -Directory -ErrorAction SilentlyContinue | Select-Object -Property * | `
            Where-Object { Test-Path $(Join-Path $_.FullName 'WinPE-Media\sources\boot.wim') } | `
            Where-Object { Test-Path $(Join-Path $_.FullName '.core\id.json') } | `
            # Where-Object { Test-Path $(Join-Path $_.FullName '.core\winos-windowsimage.xml') } | `
            Where-Object { (Test-Path $(Join-Path $_.FullName '.core\winpe-windowsimage.xml')) -or (Test-Path $(Join-Path $_.FullName '.core\winre-windowsimage.xml')) } | `
            Where-Object { Test-Path $(Join-Path $_.FullName '.core\gv-buildmedia.xml') }

        $IndexXml = (Join-Path $BuildPath 'index.xml')
        $IndexJson = (Join-Path $BuildPath 'index.json')

        if ($BuildItems.Count -eq 0) {
            Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] OSDWorkspace WinPE Builds were not found"
            Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Run Build-OSDWorkspaceWinPE to resolve this issue"
            
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
            Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] InfoId: $InfoId"
            $ImportId = Get-Content $InfoId -Raw | ConvertFrom-Json
            Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Id: $($ImportId.Id)"

            $InfoOS = "$BuildItemPath\.core\winos-windowsimage.xml"
            Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] InfoOS: $InfoOS"
            $ClixmlOS = @()
            if (Test-Path $InfoOS) {
                $ClixmlOS = Import-Clixml -Path $InfoOS -ErrorAction SilentlyContinue
            }

            $InfoREG = "$BuildItemPath\.core\winpe-regcurrentversion.xml"
            Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] InfoREG: $InfoREG"
            $ClixmlREG = @()
            $ClixmlREG = Import-Clixml -Path $InfoREG

            $InfoPE = "$BuildItemPath\.core\winpe-windowsimage.xml"
            Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] InfoPE: $InfoPE"
            $ClixmlPE = @()
            $ClixmlPE = Import-Clixml -Path $InfoPE -ErrorAction SilentlyContinue

            $InfoRE = "$BuildItemPath\.core\winre-windowsimage.xml"
            Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] InfoRE: $InfoRE"
            $ClixmlRE = @()
            if (Test-Path $InfoRE) {
                $ClixmlRE = Import-Clixml -Path $InfoRE -ErrorAction SilentlyContinue
            }

            $InfoBM = "$BuildItemPath\.core\gv-buildmedia.xml"
            Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] InfoBM: $InfoBM"
            $ClixmlBM = @()
            $ClixmlBM = Import-Clixml -Path $InfoBM

            #=================================================
            # Use ClixmlPE as this exists for WinRE and ADK
            $OSArchitecture = $ClixmlPE.Architecture
            if ($OSArchitecture -eq '0') { $OSArchitecture = 'x86' }
            if ($OSArchitecture -eq '1') { $OSArchitecture = 'MIPS' }
            if ($OSArchitecture -eq '2') { $OSArchitecture = 'Alpha' }
            if ($OSArchitecture -eq '3') { $OSArchitecture = 'PowerPC' }
            if ($OSArchitecture -eq '5') { $OSArchitecture = 'ARM' }
            if ($OSArchitecture -eq '6') { $OSArchitecture = 'ia64' }
            if ($OSArchitecture -eq '9') { $OSArchitecture = 'amd64' }
            if ($OSArchitecture -eq '12') { $OSArchitecture = 'arm64' }
            Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] OSArchitecture: $OSArchitecture"

            #=================================================
            # Alternate method is for ADK compatibility
            if ($ClixmlOS) {
                $OSEditionId = $($ClixmlOS.EditionId)
                $OSInstallationType = $($ClixmlOS.InstallationType)
                $OSCreatedTime = [datetime]$ClixmlOS.CreatedTime
                $OSModifiedTime = [datetime]$ClixmlOS.ModifiedTime
                $OSImageName = $ClixmlOS.ImageName
                $OSVersion = "$($ClixmlOS.MajorVersion).$($ClixmlOS.MinorVersion).$($ClixmlOS.Build).$($ClixmlOS.SPBuild)"
            }
            else {
                $OSEditionId = $($ClixmlPE.EditionId)
                $OSInstallationType = $($ClixmlPE.InstallationType)
                $OSCreatedTime = [datetime]$ClixmlPE.CreatedTime
                $OSModifiedTime = [datetime]$ClixmlPE.ModifiedTime
                $OSImageName = $ClixmlPE.ImageName
                $OSVersion = "$($ClixmlPE.MajorVersion).$($ClixmlPE.MinorVersion).$($ClixmlPE.Build).$($ClixmlPE.SPBuild)"
            }
            Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] OSEditionId: $OSEditionId"
            Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] OSInstallationType: $OSInstallationType"

            #=================================================
            # Alternate method is for ADK compatibility
            if ($ClixmlRE) {
                $WinREVersion = $($ClixmlRE.Version)
                $WinREMajorVersion = $($ClixmlRE.MajorVersion)
                $WinREMinorVersion = $($ClixmlRE.MinorVersion)
                $WinREBuild = $($ClixmlRE.Build)
                $WinRESPLevel = $($ClixmlRE.SPLevel)
                $WinRELanguages = $($ClixmlRE.Languages)
            }
            else {
                $WinREVersion = $($ClixmlPE.Version)
                $WinREMajorVersion = $($ClixmlPE.MajorVersion)
                $WinREMinorVersion = $($ClixmlPE.MinorVersion)
                $WinREBuild = $($ClixmlPE.Build)
                $WinRESPLevel = $($ClixmlPE.SPLevel)
                $WinRELanguages = $($ClixmlPE.Languages)
            }
            Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] WinREVersion: $WinREVersion"
            Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] WinREMajorVersion: $WinREMajorVersion"
            Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] WinREMinorVersion: $WinREMinorVersion"
            Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] WinREBuild: $WinREBuild"
            Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] WinRESPLevel: $WinRESPLevel"
            Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Languages: $WinRELanguages"
            #=================================================
            #   Create Object
            #=================================================
            $ObjectProperties = [ordered]@{
                Type                     = 'WinPE'
                Id                       = $ImportId.Id
                Name                     = $ClixmlBM.Name
                ModifiedTime             = [datetime]$ClixmlPE.ModifiedTime
                InstallationType         = $ClixmlPE.InstallationType
                Version                  = "$($ClixmlPE.MajorVersion).$($ClixmlPE.MinorVersion).$($ClixmlPE.Build).$($ClixmlPE.SPBuild)"
                DisplayVersion           = $ClixmlREG.DisplayVersion
                ReleaseId                = $ClixmlREG.ReleaseId
                Architecture             = $OSArchitecture
                Languages                = $ClixmlPE.Languages
                SetAllIntl               = $ClixmlBM.SetAllIntl
                InputLocale              = $ClixmlBM.SetInputLocale
                TimeZone                 = $ClixmlBM.SetTimeZone
                ContentStartnet          = $ClixmlBM.ContentStartnet
                ContentWinpeshl          = $ClixmlBM.ContentWinpeshl
                InstalledApps            = $ClixmlBM.InstalledApps
                AdkVersion               = $ClixmlBM.AdkInstallVersion
                BuildProfile             = $ClixmlBM.BuildProfile
                WinPEAppScript           = $ClixmlBM.WinPEAppScript
                WinPEScript              = $ClixmlBM.WinPEScript
                WinPEDriver              = $ClixmlBM.WinPEDriver
                WinPEMediaScript         = $ClixmlBM.WinPEMediaScript
                CreatedTime              = [datetime]$ClixmlPE.CreatedTime
                ImageName                = $ClixmlPE.ImageName
                ImagePath                = Join-Path $BuildItemPath 'Media\sources\boot.wim'
                ImageIndex               = [uint32]$ClixmlPE.ImageIndex
                ImageSize                = $ClixmlPE.ImageSize
                DirectoryCount           = $ClixmlPE.DirectoryCount
                FileCount                = $ClixmlPE.FileCount
                OSCreatedTime            = $OSCreatedTime
                OSModifiedTime           = $OSModifiedTime
                OSImageName              = $OSImageName
                OSEditionId              = $OSEditionId
                OSVersion                = $OSVersion
                Path                     = $BuildItemPath
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


            $WinPEBuilds = $WinPEBuilds | Sort-Object -Property ModifiedTime -Descending
            return $WinPEBuilds
        }
        else {
            return $null
        }
        #=================================================
    }
    end {
        #=================================================
        Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] End"
        #=================================================
    }
}