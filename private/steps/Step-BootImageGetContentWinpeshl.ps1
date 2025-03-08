function Step-BootImageGetContentWinpeshl {
    [CmdletBinding()]
    param (
        [System.String]
        $MountPath = $global:BuildMedia.MountPath
    )
    if (Test-Path "$MountPath\Windows\System32\winpeshl.ini") {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] winpeshl.ini Content"
        [System.String]$WinpeshlContent = Get-Content -Path "$MountPath\Windows\System32\winpeshl.ini" -Raw
        $global:BuildMedia.WinpeshlContent = $WinpeshlContent
        $global:BuildMedia.WinpeshlContent | Out-Host
    }
}