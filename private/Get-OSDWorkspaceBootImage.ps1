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
        $BootImageItems = @()
        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] BootImageItems"
        $BootImageItems = Get-ChildItem -Path (Get-OSDWorkspaceBootImagePath) -Directory -ErrorAction SilentlyContinue | Select-Object -Property * | `
            Where-Object { Test-Path $(Join-Path $_.FullName 'sources\boot.wim') } | `
            Where-Object { Test-Path $(Join-Path $_.FullName 'core\os-WindowsImage.xml') } | `
            Where-Object { Test-Path $(Join-Path $_.FullName 'core\winpe-WindowsImage.json') }

        if ($BootImageItems.Count -eq 0) {
            Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] OSDWorkspace BootImages were not found"
            Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Run Import-OSDWorkspaceBootImage to resolve this issue"
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
            #   Import OS XML
            #=================================================
            $OSXML = @()
            $OSXML = Import-Clixml -Path "$BootImageItemPath\core\os-WindowsImage.xml"
            #=================================================
            #   WindowsImageOS
            #=================================================
            $OSImageName = $($OSXML.ImageName)
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] OSImageName: $OSImageName"

            $OSArchitecture = $OSXML.Architecture
            if ($OSArchitecture -eq '0') { $OSArchitecture = 'x86' }
            if ($OSArchitecture -eq '1') { $OSArchitecture = 'MIPS' }
            if ($OSArchitecture -eq '2') { $OSArchitecture = 'Alpha' }
            if ($OSArchitecture -eq '3') { $OSArchitecture = 'PowerPC' }
            if ($OSArchitecture -eq '5') { $OSArchitecture = 'ARM' }
            if ($OSArchitecture -eq '6') { $OSArchitecture = 'ia64' }
            if ($OSArchitecture -eq '9') { $OSArchitecture = 'amd64' }
            if ($OSArchitecture -eq '12') { $OSArchitecture = 'arm64' }
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] OSArchitecture: $OSArchitecture"

            $OSEditionId = $($OSXML.EditionId)
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] OSEditionId: $OSEditionId"

            $OSInstallationType = $($OSXML.InstallationType)
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] OSInstallationType: $OSInstallationType"
            #=================================================
            #   Import WinRE XML
            #=================================================
            $WindowsImageWinRE = @()
            $WindowsImageWinRE = Import-Clixml -Path "$BootImageItemPath\core\winpe-WindowsImage.xml"
            #=================================================
            #   WindowsImageWinRE
            #=================================================
            $WinREVersion = $($WindowsImageWinRE.Version)
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] WinREVersion: $WinREVersion"

            $WinREMajorVersion = $($WindowsImageWinRE.MajorVersion)
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] WinREMajorVersion: $WinREMajorVersion"

            $WinREMinorVersion = $($WindowsImageWinRE.MinorVersion)
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] WinREMinorVersion: $WinREMinorVersion"

            $WinREBuild = $($WindowsImageWinRE.Build)
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] WinREBuild: $WinREBuild"

            $WinRESPLevel = $($WindowsImageWinRE.SPLevel)
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] WinRESPLevel: $WinRESPLevel"
            #=================================================
            #   Language
            #=================================================
            $WinRELanguages = $($WindowsImageWinRE.Languages)
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Languages: $WinRELanguages"
            #=================================================
            #   Create Object
            #=================================================
            $ObjectProperties = [ordered]@{
                Id               = Split-Path -Leaf $BootImageItemPath
                CreatedTime      = [datetime]$WindowsImageWinRE.CreatedTime
                ModifiedTime     = [datetime]$WindowsImageWinRE.ModifiedTime
                InstallationType = $WindowsImageWinRE.InstallationType
                ImageName        = $WindowsImageWinRE.ImageName
                Version          = [version]$WindowsImageWinRE.Version
                Architecture     = $OSArchitecture
                Languages        = $WindowsImageWinRE.Languages
                ImageSize        = $WindowsImageWinRE.ImageSize
                DirectoryCount   = $WindowsImageWinRE.DirectoryCount
                FileCount        = $WindowsImageWinRE.FileCount
                OSImageName      = $OSXML.ImageName
                OSEditionId      = $OSXML.EditionId
                OSVersion        = [version]$OSXML.Version
                OSCreatedTime    = [datetime]$OSXML.CreatedTime
                Path             = $BootImageItemPath
                ImagePath        = $BootImageItemPath + '\sources\boot.wim'
                ImageIndex       = $WindowsImageWinRE.ImageIndex
            }
            New-Object -TypeName PSObject -Property $ObjectProperties
            if (!(Test-Path -Path "$BootImageItemPath\BootImage.json")) {
                $ObjectProperties | ConvertTo-Json | Out-File -FilePath "$BootImageItemPath\BootImage.json" -Encoding utf8 -Force
            }
        }

        if ($OSDWorkspaceBootImage) {
            if ($Architecture -eq 'amd64') {
                $OSDWorkspaceBootImage = $OSDWorkspaceBootImage | Where-Object { $_.Architecture -eq 'amd64' }
            }
            if ($Architecture -eq 'arm64') {
                $OSDWorkspaceBootImage = $OSDWorkspaceBootImage | Where-Object { $_.Architecture -eq 'arm64' }
            }
            return $OSDWorkspaceBootImage | Sort-Object -Property Id
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