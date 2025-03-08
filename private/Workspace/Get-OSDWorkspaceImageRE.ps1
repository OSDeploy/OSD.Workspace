function Get-OSDWorkspaceImageRE {
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
        $OSDWorkspaceImageREPath = Get-OSDWorkspaceREImagePath

        $ImageItems = @()
        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] ImageItems"
        $ImageItems = Get-ChildItem -Path $OSDWorkspaceImageREPath -Directory -ErrorAction SilentlyContinue | Select-Object -Property * | `
            Where-Object { Test-Path $(Join-Path $_.FullName '.wim\winre.wim') } | `
            Where-Object { Test-Path $(Join-Path $_.FullName '.core\id.json') } | `
            Where-Object { Test-Path $(Join-Path $_.FullName '.core\os-windowsimage.xml') } | `
            Where-Object { Test-Path $(Join-Path $_.FullName '.core\re-windowsimage.xml') }

        $IndexXml = (Join-Path $OSDWorkspaceImageREPath 'index.xml')
        $IndexJson = (Join-Path $OSDWorkspaceImageREPath 'index.json')

        if ($ImageItems.Count -eq 0) {
            Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] OSDWorkspace ImageRE files were not found"
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
        $OSDWorkspaceImageRE = foreach ($ImageItem in $ImageItems) {
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

            $InfoOS = "$ImageItemPath\.core\os-windowsimage.xml"
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] InfoOS: $InfoOS"
            $ClixmlOS = @()
            $ClixmlOS = Import-Clixml -Path $InfoOS

            $InfoRE = "$ImageItemPath\.core\re-windowsimage.xml"
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
                Type             = 'ImportRE'
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

        if ($OSDWorkspaceImageRE) {
            # $OSDWorkspaceImageRE | Export-Clixml -Path $IndexXml -Force
            $OSDWorkspaceImageRE | ConvertTo-Json -Depth 1 | Out-File -FilePath $IndexJson -Encoding utf8 -Force

            if ($Architecture -eq 'amd64') {
                $OSDWorkspaceImageRE = $OSDWorkspaceImageRE | Where-Object { $_.Architecture -eq 'amd64' }
            }
            if ($Architecture -eq 'arm64') {
                $OSDWorkspaceImageRE = $OSDWorkspaceImageRE | Where-Object { $_.Architecture -eq 'arm64' }
            }
            return $OSDWorkspaceImageRE | Sort-Object -Property ModifiedTime -Descending
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