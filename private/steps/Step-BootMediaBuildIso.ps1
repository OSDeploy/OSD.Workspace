function Step-BootMediaBuildIso {
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
    $BootIsoPath = Join-Path $BootMediaRootPath 'BootISO'
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Creating bootable ISO [$BootIsoPath]"
    if (-not (Test-Path $BootIsoPath)) { New-Item -Path $BootIsoPath -ItemType Directory -Force | Out-Null }
    $Params = @{
        MediaPath      = $MediaPath
        IsoFileName    = $BootMediaIsoName
        IsoLabel       = $BootMediaIsoLabel
        WindowsAdkRoot = $WindowsAdkRootPath
        IsoDirectory   = $BootIsoPath
    }
    New-WindowsAdkISO @Params | Out-Null

    if ($MediaPathEX) {
        $Params = @{
            MediaPath      = $MediaPathEX
            IsoFileName    = $BootMediaIsoNameEX
            IsoLabel       = $BootMediaIsoLabel
            WindowsAdkRoot = $WindowsAdkRootPath
            IsoDirectory   = $BootIsoPath
        }
        New-WindowsAdkISO @Params | Out-Null
    }
}