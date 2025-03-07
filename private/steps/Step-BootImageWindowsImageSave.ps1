function Step-BootImageWindowsImageSave {
    [CmdletBinding()]
    param (
        $WindowsImage = $global:WindowsImage,
        $BootMediaLogs = $global:BootMediaLogs
    )
    #=================================================
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Save Windows Image"
    $CurrentLog = "$BootMediaLogs\$((Get-Date).ToString('yyMMdd-HHmmss'))-Save-WindowsImage.log"
    $WindowsImage | Save-WindowsImage -LogPath $CurrentLog | Out-Null
    #=================================================
}