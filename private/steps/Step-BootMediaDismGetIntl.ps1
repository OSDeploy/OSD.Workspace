function Step-BootImageDismGetIntl {
    [CmdletBinding()]
    param (
        [System.String]
        $MountPath = $global:BootMedia.MountPath,
        $BootMediaLogs = $global:BootMediaLogs
    )
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] DISM Get-Intl Configuration"
    $CurrentLog = "$BootMediaLogs\$((Get-Date).ToString('yyMMdd-HHmmss'))-Get-Intl.log"
    dism.exe /image:"$MountPath" /Get-Intl /LogPath:"$CurrentLog"
}