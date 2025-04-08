function Step-BuildMediaIso {
    [CmdletBinding()]
    param (
        [System.String]
        $AdkRootPath = $global:BuildMedia.AdkRootPath,
        [System.String]
        $MediaIsoLabel = $global:BuildMedia.MediaIsoLabel,
        [System.String]
        $MediaIsoName = $global:BuildMedia.MediaIsoName,
        [System.String]
        $MediaIsoNameEX = $global:BuildMedia.MediaIsoNameEX,
        [System.String]
        $MediaPath = $global:BuildMedia.MediaPath,
        [System.String]
        $MediaPathEX = $global:BuildMedia.MediaPathEX,
        [System.String]
        $MediaRootPath = $global:BuildMedia.MediaRootPath
    )
    #=================================================
    $Error.Clear()
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Start"
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] AdkRootPath: $AdkRootPath"
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] MediaIsoLabel: $MediaIsoLabel"
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] MediaIsoName: $MediaIsoName"
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] MediaIsoNameEX: $MediaIsoNameEX"
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] MediaPath: $MediaPath"
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] MediaPathEX: $MediaPathEX"
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] MediaRootPath: $MediaRootPath"
    #=================================================
    $IsoPath = Join-Path $MediaRootPath 'ISO'
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Creating bootable ISO [$IsoPath]"
    if (-not (Test-Path $IsoPath)) { New-Item -Path $IsoPath -ItemType Directory -Force | Out-Null }
    $Params = @{
        MediaPath      = $MediaPath
        IsoFileName    = $MediaIsoName
        IsoLabel       = $MediaIsoLabel
        WindowsAdkRoot = $AdkRootPath
        IsoDirectory   = $IsoPath
    }
    New-WindowsAdkISO @Params | Out-Null

    if ($MediaPathEX) {
        $Params = @{
            MediaPath      = $MediaPathEX
            IsoFileName    = $MediaIsoNameEX
            IsoLabel       = $MediaIsoLabel
            WindowsAdkRoot = $AdkRootPath
            IsoDirectory   = $IsoPath
        }
        New-WindowsAdkISO @Params | Out-Null
    }
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}