function Step-BootMediaIso {
    [CmdletBinding()]
    param (
        [System.String]
        $BuildMediaIsoLabel = $global:BuildMedia.BuildMediaIsoLabel,
        [System.String]
        $BuildMediaIsoName = $global:BuildMedia.BuildMediaIsoName,
        [System.String]
        $BuildMediaIsoNameEX = $global:BuildMedia.BuildMediaIsoNameEX,
        [System.String]
        $BuildMediaRootPath = $global:BuildMedia.BuildMediaRootPath,
        [System.String]
        $MediaPath = $global:BuildMedia.MediaPath,
        [System.String]
        $MediaPathEX = $global:BuildMedia.MediaPathEX,
        [System.String]
        $WindowsAdkRootPath = $global:BuildMedia.AdkRootPath
    )
    $IsoPath = Join-Path $BuildMediaRootPath 'ISO'
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Creating bootable ISO [$IsoPath]"
    if (-not (Test-Path $IsoPath)) { New-Item -Path $IsoPath -ItemType Directory -Force | Out-Null }
    $Params = @{
        MediaPath      = $MediaPath
        IsoFileName    = $BuildMediaIsoName
        IsoLabel       = $BuildMediaIsoLabel
        WindowsAdkRoot = $WindowsAdkRootPath
        IsoDirectory   = $IsoPath
    }
    New-WindowsAdkISO @Params | Out-Null

    if ($MediaPathEX) {
        $Params = @{
            MediaPath      = $MediaPathEX
            IsoFileName    = $BuildMediaIsoNameEX
            IsoLabel       = $BuildMediaIsoLabel
            WindowsAdkRoot = $WindowsAdkRootPath
            IsoDirectory   = $IsoPath
        }
        New-WindowsAdkISO @Params | Out-Null
    }
}