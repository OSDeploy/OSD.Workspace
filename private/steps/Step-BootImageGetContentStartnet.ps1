function Step-BootImageGetContentStartnet {
    [CmdletBinding()]
    param (
        [System.String]
        $MountPath = $global:BootMedia.MountPath
    )
    if (Test-Path "$MountPath\Windows\System32\startnet.cmd") {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Startnet.cmd Content"
        [System.String]$StartnetContent = Get-Content -Path "$MountPath\Windows\System32\startnet.cmd" -Raw
        $global:BootMedia.StartnetContent = $StartnetContent
        $global:BootMedia.StartnetContent | Out-Host
    }
}