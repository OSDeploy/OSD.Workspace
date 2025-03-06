function Step-BootImageRemoveWinpeshl {
    [CmdletBinding()]
    param (
        [System.String]
        $MountPath = $global:BootMedia.MountPath
    )
    $Winpeshl = "$MountPath\Windows\System32\winpeshl.ini"
    if (Test-Path $Winpeshl) {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Removing WinRE $Winpeshl"
        Remove-Item -Path $Winpeshl -Force
    }
}