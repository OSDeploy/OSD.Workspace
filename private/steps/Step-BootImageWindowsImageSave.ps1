function Step-BootImageWindowsImageSave {
    [CmdletBinding()]
    param (
        $WindowsImage = $global:WindowsImage,
        $BuildMediaLogs = $global:BuildMediaLogs
    )
    #=================================================
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Save Windows Image"
    $CurrentLog = "$BuildMediaLogs\$((Get-Date).ToString('yyMMdd-HHmmss'))-Save-windowsimage.log"
    $WindowsImage | Save-WindowsImage -LogPath $CurrentLog | Out-Null
    #=================================================
}