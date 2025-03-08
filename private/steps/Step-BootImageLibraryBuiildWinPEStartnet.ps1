function Step-BootImageLibraryBuiildWinPEStartnet {
    [CmdletBinding()]
    param (
        [System.String]
        $MountPath = $global:BuildMedia.MountPath,
        $BuildWinPEStartnet = $global:BuildMedia.BuildWinPEStartnet
    )
    foreach ($Item in $BuildWinPEStartnet) {
        if (Test-Path $Item) {
            Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Startnet.cmd: $Item"
            Copy-Item -Path $Item -Destination "$MountPath\Windows\System32\Startnet.cmd" -Force -Verbose
        }
        else {
            Write-Warning "BootImage Startnet $Item (not found)"
        }
    }
}