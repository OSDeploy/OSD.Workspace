function Get-OSDWSWinOSSource {
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
        $SourcePath = Get-OSDWSWinOSSourcePath

        $SourceItems = @()
        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] ImageItems"
        $SourceItems = Get-ChildItem -Path $SourcePath -Directory -ErrorAction SilentlyContinue | Select-Object -Property * | `
            Where-Object { Test-Path $(Join-Path $_.FullName 'WinOS-Media\sources\install.wim') } | `
            Where-Object { Test-Path $(Join-Path $_.FullName '.core\id.json') } | `
            Where-Object { Test-Path $(Join-Path $_.FullName '.core\winos-windowsimage.xml') }

        $IndexXml = (Join-Path $SourcePath 'index.xml')
        $IndexJson = (Join-Path $SourcePath 'index.json')

        if ($SourceItems.Count -eq 0) {
            Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] OSDWorkspace Import WinOS files were not found"
            Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Run Import-OSDWorkspaceWinOS to resolve this issue"

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
        $WinOSSources = foreach ($SourceItem in $SourceItems) {
            #=================================================
            #   Get-FullName
            #=================================================
            $SourceItemPath = $($SourceItem.FullName)
            #=================================================
            #   Import Details
            #=================================================
            $InfoId = "$SourceItemPath\.core\id.json"
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] InfoId: $InfoId"
            $ImportId = Get-Content $InfoId -Raw | ConvertFrom-Json
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Id: $($ImportId.Id)"

            $InfoOS = "$SourceItemPath\.core\winos-windowsimage.xml"
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] InfoOS: $InfoOS"
            $ClixmlOS = @()
            $ClixmlOS = Import-Clixml -Path $InfoOS
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
            #=================================================
            #   Create Object
            #=================================================
            $ObjectProperties = [ordered]@{
                Type             = 'WinOS'
                Id               = $ImportId.Id
                Name             = $SourceItem.Name
                CreatedTime      = [datetime]$ClixmlOS.CreatedTime
                ModifiedTime     = [datetime]$ClixmlOS.ModifiedTime
                InstallationType = $ClixmlOS.InstallationType
                Version          = [System.String]"$($ClixmlOS.MajorVersion).$($ClixmlOS.MinorVersion).$($ClixmlOS.Build).$($ClixmlOS.SPBuild)"
                Architecture     = $OSArchitecture
                Languages        = $ClixmlOS.Languages
                ImageSize        = $ClixmlOS.ImageSize
                DirectoryCount   = $ClixmlOS.DirectoryCount
                FileCount        = $ClixmlOS.FileCount
                ImageName        = $ClixmlOS.ImageName
                EditionId        = $ClixmlOS.EditionId
                Path             = $SourceItemPath
                ImagePath        = $SourceItemPath + '\Media\sources\install.wim'
                ImageIndex       = [uint32]$ClixmlOS.ImageIndex
                ImageDescription = $ClixmlOS.ImageDescription
                WIMBoot          = $ClixmlOS.WIMBoot
                ImageType        = $ClixmlOS.ImageType
                ProductName      = $ClixmlOS.ProductName
                Hal              = $ClixmlOS.Hal
                ProductType      = $ClixmlOS.ProductType
                ProductSuite     = $ClixmlOS.ProductSuite
                MajorVersion     = $ClixmlOS.MajorVersion
                MinorVersion     = $ClixmlOS.MinorVersion
                Build            = $ClixmlOS.Build
                SPBuild          = $ClixmlOS.SPBuild
                SPLevel          = $ClixmlOS.SPLevel
                ImageBootable    = $ClixmlOS.ImageBootable
                SystemRoot       = $ClixmlOS.SystemRoot
                DefaultLanguageIndex = $ClixmlOS.DefaultLanguageIndex
            }
            New-Object -TypeName PSObject -Property $ObjectProperties
            $ObjectProperties | Export-Clixml -Path "$SourceItemPath\.core\object.xml" -Force
            $ObjectProperties | ConvertTo-Json -Depth 5 | Out-File -FilePath "$SourceItemPath\.core\object.json" -Encoding utf8 -Force
            $ObjectProperties | ConvertTo-Json -Depth 5 | Out-File -FilePath "$SourceItemPath\properties.json" -Encoding utf8 -Force
        }

        if ($WinOSSources) {
            # $WinOSSources | Export-Clixml -Path $IndexXml -Force
            $WinOSSources | ConvertTo-Json -Depth 5 | Out-File -FilePath $IndexJson -Encoding utf8 -Force

            if ($Architecture -eq 'amd64') {
                $WinOSSources = $WinOSSources | Where-Object { $_.Architecture -eq 'amd64' }
            }
            if ($Architecture -eq 'arm64') {
                $WinOSSources = $WinOSSources | Where-Object { $_.Architecture -eq 'arm64' }
            }
            return $WinOSSources | Sort-Object -Property ModifiedTime -Descending
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