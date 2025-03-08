function Get-OSDWorkspaceImportWinRE {
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
        $OSDWorkspaceImportWinREPath = Get-OSDWorkspaceImportWinREPath

        $ImageItems = @()
        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] ImageItems"
        $ImageItems = Get-ChildItem -Path $OSDWorkspaceImportWinREPath -Directory -ErrorAction SilentlyContinue | Select-Object -Property * | `
            Where-Object { Test-Path $(Join-Path $_.FullName '.wim\winre.wim') } | `
            Where-Object { Test-Path $(Join-Path $_.FullName '.core\id.json') } | `
            Where-Object { Test-Path $(Join-Path $_.FullName '.core\winos-windowsimage.xml') } | `
            Where-Object { Test-Path $(Join-Path $_.FullName '.core\winre-windowsimage.xml') }

        $IndexXml = (Join-Path $OSDWorkspaceImportWinREPath 'index.xml')
        $IndexJson = (Join-Path $OSDWorkspaceImportWinREPath 'index.json')

        if ($ImageItems.Count -eq 0) {
            Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] OSDWorkspace Import WinRE files were not found"
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
        $OSDWorkspaceImportWinRE = foreach ($ImageItem in $ImageItems) {
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

            $InfoRE = "$ImageItemPath\.core\winre-windowsimage.xml"
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] InfoRE: $InfoRE"
            $ClixmlRE = @()
            $ClixmlRE = Import-Clixml -Path $InfoRE
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
                Type             = 'WinRE'
                Id               = $ImportId.Id
                Name             = $ImageItem.Name
                CreatedTime      = [datetime]$ClixmlRE.CreatedTime
                ModifiedTime     = [datetime]$ClixmlRE.ModifiedTime
                InstallationType = $ClixmlRE.InstallationType
                Version          = [System.String]"$($ClixmlRE.MajorVersion).$($ClixmlRE.MinorVersion).$($ClixmlRE.Build).$($ClixmlRE.SPBuild)"
                Architecture     = $OSArchitecture
                Languages        = $ClixmlRE.Languages
                ImageSize        = $ClixmlRE.ImageSize
                DirectoryCount   = $ClixmlRE.DirectoryCount
                FileCount        = $ClixmlRE.FileCount
                ImageName        = $ClixmlRE.ImageName
                OSImageName      = $ClixmlOS.ImageName
                OSEditionId      = $ClixmlOS.EditionId
                OSVersion        = [System.String]"$($ClixmlOS.MajorVersion).$($ClixmlOS.MinorVersion).$($ClixmlOS.Build).$($ClixmlOS.SPBuild)"
                OSCreatedTime    = [datetime]$ClixmlOS.CreatedTime
                OSModifiedTime   = [datetime]$ClixmlOS.ModifiedTime
                Path             = $ImageItemPath
                ImagePath        = $ImageItemPath + '\.wim\winre.wim'
                ImageIndex       = [uint32]$ClixmlRE.ImageIndex
            }
            New-Object -TypeName PSObject -Property $ObjectProperties
            $ObjectProperties | Export-Clixml -Path "$ImageItemPath\.core\object.xml" -Force
            $ObjectProperties | ConvertTo-Json -Depth 1 | Out-File -FilePath "$ImageItemPath\.core\object.json" -Encoding utf8 -Force
            $ObjectProperties | ConvertTo-Json -Depth 1 | Out-File -FilePath "$ImageItemPath\properties.json" -Encoding utf8 -Force
        }

        if ($OSDWorkspaceImportWinRE) {
            # $OSDWorkspaceImportWinRE | Export-Clixml -Path $IndexXml -Force
            $OSDWorkspaceImportWinRE | ConvertTo-Json -Depth 1 | Out-File -FilePath $IndexJson -Encoding utf8 -Force

            if ($Architecture -eq 'amd64') {
                $OSDWorkspaceImportWinRE = $OSDWorkspaceImportWinRE | Where-Object { $_.Architecture -eq 'amd64' }
            }
            if ($Architecture -eq 'arm64') {
                $OSDWorkspaceImportWinRE = $OSDWorkspaceImportWinRE | Where-Object { $_.Architecture -eq 'arm64' }
            }
            return $OSDWorkspaceImportWinRE | Sort-Object -Property ModifiedTime -Descending
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