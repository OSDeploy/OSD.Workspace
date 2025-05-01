function Get-OSDWSWinRESource {
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
        $SourcePath = $OSDWorkspace.paths.import_windows_re

        $SourceItems = @()
        Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] ImageItems"
        $SourceItems = Get-ChildItem -Path $SourcePath -Directory -ErrorAction SilentlyContinue | Select-Object -Property * | `
            Where-Object { Test-Path $(Join-Path $_.FullName '.wim\winre.wim') } | `
            Where-Object { Test-Path $(Join-Path $_.FullName '.core\id.json') } | `
            Where-Object { Test-Path $(Join-Path $_.FullName '.core\winos-windowsimage.xml') } | `
            Where-Object { Test-Path $(Join-Path $_.FullName '.core\winre-windowsimage.xml') }

        $IndexXml = (Join-Path $SourcePath 'index.xml')
        $IndexJson = (Join-Path $SourcePath 'index.json')

        if ($SourceItems.Count -eq 0) {
            Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] OSDWorkspace Import WinRE files were not found"
            Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Run Import-OSDWorkspaceWinOS to resolve this issue"

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
        $WinRESources = foreach ($SourceItem in $SourceItems) {
            #=================================================
            #   Get-FullName
            #=================================================
            $SourceItemPath = $($SourceItem.FullName)
            #=================================================
            #   Import Details
            #=================================================
            $InfoId = "$SourceItemPath\.core\id.json"
            Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] InfoId: $InfoId"
            $ImportId = Get-Content $InfoId -Raw | ConvertFrom-Json
            Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Id: $($ImportId.Id)"

            $InfoOS = "$SourceItemPath\.core\winos-windowsimage.xml"
            Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] InfoOS: $InfoOS"
            $ClixmlOS = @()
            $ClixmlOS = Import-Clixml -Path $InfoOS

            $InfoRE = "$SourceItemPath\.core\winre-windowsimage.xml"
            Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] InfoRE: $InfoRE"
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
                Name             = $SourceItem.Name
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
                Path             = $SourceItemPath
                ImagePath        = $SourceItemPath + '\.wim\winre.wim'
                ImageIndex       = [uint32]$ClixmlRE.ImageIndex
            }
            New-Object -TypeName PSObject -Property $ObjectProperties
            $ObjectProperties | Export-Clixml -Path "$SourceItemPath\.core\object.xml" -Force
            $ObjectProperties | ConvertTo-Json -Depth 5 | Out-File -FilePath "$SourceItemPath\.core\object.json" -Encoding utf8 -Force
            $ObjectProperties | ConvertTo-Json -Depth 5 | Out-File -FilePath "$SourceItemPath\properties.json" -Encoding utf8 -Force
        }

        if ($WinRESources) {
            # $WinRESources | Export-Clixml -Path $IndexXml -Force
            $WinRESources | ConvertTo-Json -Depth 5 | Out-File -FilePath $IndexJson -Encoding utf8 -Force

            if ($Architecture -eq 'amd64') {
                $WinRESources = $WinRESources | Where-Object { $_.Architecture -eq 'amd64' }
            }
            if ($Architecture -eq 'arm64') {
                $WinRESources = $WinRESources | Where-Object { $_.Architecture -eq 'arm64' }
            }

            $WinRESources = $WinRESources | Sort-Object -Property Name
            return $WinRESources
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