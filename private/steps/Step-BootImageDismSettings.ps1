function Step-BootImageDismSettings {
    [CmdletBinding()]
    param (
        [System.String]
        $MountPath = $global:BuildMedia.MountPath,
        $BuildMediaLogs = $global:BuildMediaLogs,
        $TimeZone = $global:BuildMedia.TimeZone,
        $SetAllIntl = $global:BuildMedia.SetAllIntl,
        $SetInputLocale = $global:BuildMedia.SetInputLocale
    )
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Set-TimeZone to $TimeZone"
    $CurrentLog = "$BuildMediaLogs\$((Get-Date).ToString('yyMMdd-HHmmss'))-Set-TimeZone.log"
    dism.exe /quiet /image:"$MountPath" /Set-TimeZone:"$TimeZone" /LogPath:"$CurrentLog"

    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Log current Get-Intl configuration"
    $CurrentLog = "$BuildMediaLogs\$((Get-Date).ToString('yyMMdd-HHmmss'))-Get-Intl.log"
    dism.exe /quiet /image:"$MountPath" /Get-Intl /LogPath:"$CurrentLog"

    if ($SetAllIntl) {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Set-AllIntl to $SetAllIntl"
        $CurrentLog = "$BuildMediaLogs\$((Get-Date).ToString('yyMMdd-HHmmss'))-Set-AllIntl.log"
        dism.exe /quiet /image:"$MountPath" /Set-AllIntl:$SetAllIntl /LogPath:"$CurrentLog"
    }

    if ($SetInputLocale) {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Set-InputLocale to $SetInputLocale"
        $CurrentLog = "$BuildMediaLogs\$((Get-Date).ToString('yyMMdd-HHmmss'))-Set-InputLocale.log"
        dism.exe /quiet /image:"$MountPath" /Set-InputLocale:$SetInputLocale /LogPath:"$CurrentLog"
    }
}