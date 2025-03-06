function Step-BootImageLibraryBootStartnet {
    [CmdletBinding()]
    param (
        [System.String]
        $MountPath = $global:BootMedia.MountPath,
        $BootStartnet = $global:BootMedia.BootStartnet
    )
    foreach ($Item in $BootStartnet) {
        if (Test-Path $Item) {
            Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Startnet.cmd: $Item"
            Copy-Item -Path $Item -Destination "$MountPath\Windows\System32\Startnet.cmd" -Force -Verbose
        }
        else {
            Write-Warning "BootImage Startnet $Item (not found)"
        }
    }
}