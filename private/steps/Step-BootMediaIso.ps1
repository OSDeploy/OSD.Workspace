function Step-BootMediaIso {
    [CmdletBinding()]
    param (
        [System.String]
        $MediaIsoLabel = $global:BuildMedia.MediaIsoLabel,
        [System.String]
        $MediaIsoName = $global:BuildMedia.MediaIsoName,
        [System.String]
        $MediaIsoNameEX = $global:BuildMedia.MediaIsoNameEX,
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
        IsoFileName    = $MediaIsoName
        IsoLabel       = $MediaIsoLabel
        WindowsAdkRoot = $WindowsAdkRootPath
        IsoDirectory   = $IsoPath
    }
    New-WindowsAdkISO @Params | Out-Null

    if ($MediaPathEX) {
        $Params = @{
            MediaPath      = $MediaPathEX
            IsoFileName    = $MediaIsoNameEX
            IsoLabel       = $MediaIsoLabel
            WindowsAdkRoot = $WindowsAdkRootPath
            IsoDirectory   = $IsoPath
        }
        New-WindowsAdkISO @Params | Out-Null
    }
}