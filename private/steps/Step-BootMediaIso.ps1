function Step-BootMediaIso {
    [CmdletBinding()]
    param (
        [System.String]
        $BootMediaIsoLabel = $global:BootMedia.BootMediaIsoLabel,
        [System.String]
        $BootMediaIsoName = $global:BootMedia.BootMediaIsoName,
        [System.String]
        $BootMediaIsoNameEX = $global:BootMedia.BootMediaIsoNameEX,
        [System.String]
        $BootMediaRootPath = $global:BootMedia.BootMediaRootPath,
        [System.String]
        $MediaPath = $global:BootMedia.MediaPath,
        [System.String]
        $MediaPathEX = $global:BootMedia.MediaPathEX,
        [System.String]
        $WindowsAdkRootPath = $global:BootMedia.AdkRootPath
    )
    $IsoPath = Join-Path $BootMediaRootPath 'ISO'
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Creating bootable ISO [$IsoPath]"
    if (-not (Test-Path $IsoPath)) { New-Item -Path $IsoPath -ItemType Directory -Force | Out-Null }
    $Params = @{
        MediaPath      = $MediaPath
        IsoFileName    = $BootMediaIsoName
        IsoLabel       = $BootMediaIsoLabel
        WindowsAdkRoot = $WindowsAdkRootPath
        IsoDirectory   = $IsoPath
    }
    New-WindowsAdkISO @Params | Out-Null

    if ($MediaPathEX) {
        $Params = @{
            MediaPath      = $MediaPathEX
            IsoFileName    = $BootMediaIsoNameEX
            IsoLabel       = $BootMediaIsoLabel
            WindowsAdkRoot = $WindowsAdkRootPath
            IsoDirectory   = $IsoPath
        }
        New-WindowsAdkISO @Params | Out-Null
    }
}