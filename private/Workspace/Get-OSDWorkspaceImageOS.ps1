function Get-OSDWorkspaceImageOS {
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
        $OSDWorkspaceOSImagePath = Get-OSDWorkspaceImageOSPath

        $OSImageItems = @()
        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] OSImageItems"
        $OSImageItems = Get-ChildItem -Path $OSDWorkspaceOSImagePath -Directory -ErrorAction SilentlyContinue | Select-Object -Property * | `
            Where-Object { Test-Path $(Join-Path $_.FullName 'OSMedia\sources\install.wim') } | `
            Where-Object { Test-Path $(Join-Path $_.FullName '.core\id.json') } | `
            Where-Object { Test-Path $(Join-Path $_.FullName '.core\os-WindowsImage.xml') }

        $IndexXml = (Join-Path $OSDWorkspaceOSImagePath 'index.xml')
        $IndexJson = (Join-Path $OSDWorkspaceOSImagePath 'index.json')

        if ($OSImageItems.Count -eq 0) {
            Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] OSDWorkspace OSImages were not found"
            Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Run Import-OSDWorkspaceImageOS to resolve this issue"

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
        $OSDWorkspaceOSImage = foreach ($OSImageItem in $OSImageItems) {
            #=================================================
            #   Get-FullName
            #=================================================
            $OSImageItemPath = $($OSImageItem.FullName)
            #=================================================
            #   Import Details
            #=================================================
            $InfoId = "$OSImageItemPath\.core\id.json"
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] InfoId: $InfoId"
            $ImportId = Get-Content $InfoId -Raw | ConvertFrom-Json
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Id: $($ImportId.Id)"

            $InfoOS = "$OSImageItemPath\.core\os-WindowsImage.xml"
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
                Type             = 'OSImage'
                Id               = $ImportId.Id
                Name             = $OSImageItem.Name
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
                Path             = $OSImageItemPath
                ImagePath        = $OSImageItemPath + '\Media\sources\install.wim'
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
            $ObjectProperties | Export-Clixml -Path "$OSImageItemPath\.core\OSImage.xml" -Force
            $ObjectProperties | ConvertTo-Json -Depth 1 | Out-File -FilePath "$OSImageItemPath\.core\OSImage.json" -Encoding utf8 -Force
            $ObjectProperties | ConvertTo-Json -Depth 1 | Out-File -FilePath "$OSImageItemPath\properties.json" -Encoding utf8 -Force
        }

        if ($OSDWorkspaceOSImage) {
            # $OSDWorkspaceOSImage | Export-Clixml -Path $IndexXml -Force
            $OSDWorkspaceOSImage | ConvertTo-Json -Depth 1 | Out-File -FilePath $IndexJson -Encoding utf8 -Force

            if ($Architecture -eq 'amd64') {
                $OSDWorkspaceOSImage = $OSDWorkspaceOSImage | Where-Object { $_.Architecture -eq 'amd64' }
            }
            if ($Architecture -eq 'arm64') {
                $OSDWorkspaceOSImage = $OSDWorkspaceOSImage | Where-Object { $_.Architecture -eq 'arm64' }
            }
            return $OSDWorkspaceOSImage | Sort-Object -Property ModifiedTime -Descending
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