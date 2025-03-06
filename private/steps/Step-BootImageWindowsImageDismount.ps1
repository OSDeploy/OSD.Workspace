function Step-BootImageWindowsImageDismount {
    [CmdletBinding()]
    param (
        $WindowsImage = $global:WindowsImage,
        $BootMediaLogs = $global:BootMediaLogs
    )
    #=================================================
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Dismount-WindowsImage Save"
    $CurrentLog = "$BootMediaLogs\$((Get-Date).ToString('yyMMdd-HHmmss'))-Dismount-WindowsImage.log"
    $WindowsImage | Dismount-WindowsImage -Save -LogPath $CurrentLog | Out-Null
    #=================================================
}