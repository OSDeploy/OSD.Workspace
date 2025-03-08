function Get-OSDWorkspaceImportWinOS {
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
        $OSDWorkspaceImageOSPath = Get-OSDWorkspaceImportWinOSPath

        $ImageItems = @()
        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] ImageItems"
        $ImageItems = Get-ChildItem -Path $OSDWorkspaceImageOSPath -Directory -ErrorAction SilentlyContinue | Select-Object -Property * | `
            Where-Object { Test-Path $(Join-Path $_.FullName 'WinOS-Media\sources\install.wim') } | `
            Where-Object { Test-Path $(Join-Path $_.FullName '.core\id.json') } | `
            Where-Object { Test-Path $(Join-Path $_.FullName '.core\winos-windowsimage.xml') }

        $IndexXml = (Join-Path $OSDWorkspaceImageOSPath 'index.xml')
        $IndexJson = (Join-Path $OSDWorkspaceImageOSPath 'index.json')

        if ($ImageItems.Count -eq 0) {
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
        $OSDWorkspaceImageOS = foreach ($ImageItem in $ImageItems) {
            #=================================================
            #   Get-FullName
            #=================================================
            $ImageItemPath = $($ImageItem.FullName)
            #=================================================
            #   Import Details
            #=================================================
            $InfoId = "$ImageItemPath\.core\id.json"
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] InfoId: $InfoId"
            $ImportId = Get-Content $InfoId -Raw | ConvertFrom-Json
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Id: $($ImportId.Id)"

            $InfoOS = "$ImageItemPath\.core\winos-windowsimage.xml"
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
                Name             = $ImageItem.Name
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
                Path             = $ImageItemPath
                ImagePath        = $ImageItemPath + '\Media\sources\install.wim'
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
            $ObjectProperties | Export-Clixml -Path "$ImageItemPath\.core\object.xml" -Force
            $ObjectProperties | ConvertTo-Json -Depth 1 | Out-File -FilePath "$ImageItemPath\.core\object.json" -Encoding utf8 -Force
            $ObjectProperties | ConvertTo-Json -Depth 1 | Out-File -FilePath "$ImageItemPath\properties.json" -Encoding utf8 -Force
        }

        if ($OSDWorkspaceImageOS) {
            # $OSDWorkspaceImageOS | Export-Clixml -Path $IndexXml -Force
            $OSDWorkspaceImageOS | ConvertTo-Json -Depth 1 | Out-File -FilePath $IndexJson -Encoding utf8 -Force

            if ($Architecture -eq 'amd64') {
                $OSDWorkspaceImageOS = $OSDWorkspaceImageOS | Where-Object { $_.Architecture -eq 'amd64' }
            }
            if ($Architecture -eq 'arm64') {
                $OSDWorkspaceImageOS = $OSDWorkspaceImageOS | Where-Object { $_.Architecture -eq 'arm64' }
            }
            return $OSDWorkspaceImageOS | Sort-Object -Property ModifiedTime -Descending
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