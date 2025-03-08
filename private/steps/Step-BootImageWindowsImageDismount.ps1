function Step-BootImageWindowsImageDismount {
    [CmdletBinding()]
    param (
        $WindowsImage = $global:WindowsImage,
        $BuildMediaLogs = $global:BuildMediaLogs
    )
    #=================================================
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Dismount-WindowsImage Save"
    $CurrentLog = "$BuildMediaLogs\$((Get-Date).ToString('yyMMdd-HHmmss'))-Dismount-windowsimage.log"
    $WindowsImage | Dismount-WindowsImage -Save -LogPath $CurrentLog | Out-Null
    #=================================================
}