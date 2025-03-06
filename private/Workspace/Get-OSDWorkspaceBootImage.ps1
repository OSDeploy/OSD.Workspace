function Get-OSDWorkspaceBootImage {
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
        $OSWorkspaceBootImagePath = Get-OSDWorkspaceBootImagePath

        $BootImageItems = @()
        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] BootImageItems"
        $BootImageItems = Get-ChildItem -Path $OSWorkspaceBootImagePath -Directory -ErrorAction SilentlyContinue | Select-Object -Property * | `
            Where-Object { Test-Path $(Join-Path $_.FullName 'sources\boot.wim') } | `
            Where-Object { Test-Path $(Join-Path $_.FullName 'core\id.json') } | `
            Where-Object { Test-Path $(Join-Path $_.FullName 'core\os-WindowsImage.xml') } | `
            Where-Object { Test-Path $(Join-Path $_.FullName 'core\re-WindowsImage.xml') }

        $IndexXml = (Join-Path $OSWorkspaceBootImagePath 'index.xml')
        $IndexJson = (Join-Path $OSWorkspaceBootImagePath 'index.json')

        if ($BootImageItems.Count -eq 0) {
            Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] OSDWorkspace BootImages were not found"
            Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Run Import-OSDWorkspaceBootImage to resolve this issue"

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
        $OSDWorkspaceBootImage = foreach ($BootImageItem in $BootImageItems) {
            #=================================================
            #   Get-FullName
            #=================================================
            $BootImageItemPath = $($BootImageItem.FullName)
            #=================================================
            #   Import Details
            #=================================================
            $InfoId = "$BootImageItemPath\core\id.json"
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] InfoId: $InfoId"
            $ImportId = Get-Content $InfoId -Raw | ConvertFrom-Json
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Id: $($ImportId.Id)"

            $InfoOS = "$BootImageItemPath\core\os-WindowsImage.xml"
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] InfoOS: $InfoOS"
            $ClixmlOS = @()
            $ClixmlOS = Import-Clixml -Path $InfoOS

            $InfoRE = "$BootImageItemPath\core\re-WindowsImage.xml"
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
                Type             = 'BootImage'
                Id               = $ImportId.Id
                Name             = $BootImageItem.Name
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
                Path             = $BootImageItemPath
                ImagePath        = $BootImageItemPath + '\sources\boot.wim'
                ImageIndex       = [uint32]$ClixmlRE.ImageIndex
            }
            New-Object -TypeName PSObject -Property $ObjectProperties
            $ObjectProperties | Export-Clixml -Path "$BootImageItemPath\core\BootImage.xml" -Force
            $ObjectProperties | ConvertTo-Json -Depth 1 | Out-File -FilePath "$BootImageItemPath\core\BootImage.json" -Encoding utf8 -Force
            $ObjectProperties | ConvertTo-Json -Depth 1 | Out-File -FilePath "$BootImageItemPath\properties.json" -Encoding utf8 -Force
        }

        if ($OSDWorkspaceBootImage) {
            # $OSDWorkspaceBootImage | Export-Clixml -Path $IndexXml -Force
            $OSDWorkspaceBootImage | ConvertTo-Json -Depth 1 | Out-File -FilePath $IndexJson -Encoding utf8 -Force

            if ($Architecture -eq 'amd64') {
                $OSDWorkspaceBootImage = $OSDWorkspaceBootImage | Where-Object { $_.Architecture -eq 'amd64' }
            }
            if ($Architecture -eq 'arm64') {
                $OSDWorkspaceBootImage = $OSDWorkspaceBootImage | Where-Object { $_.Architecture -eq 'arm64' }
            }
            return $OSDWorkspaceBootImage | Sort-Object -Property ModifiedTime -Descending
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