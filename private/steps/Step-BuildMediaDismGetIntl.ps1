function Step-BuildMediaDismGetIntl {
    [CmdletBinding()]
    param (
        [System.String]
        $MountPath = $global:BuildMedia.MountPath,
        [System.String]
        $LogsPath = $global:BuildMediaLogsPath
    )
    #=================================================
    $Error.Clear()
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] MountPath: $MountPath"
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] LogsPath: $LogsPath"
    #=================================================
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] DISM Get-Intl Configuration"
    $CurrentLog = "$LogsPath\$((Get-Date).ToString('yyMMdd-HHmmss'))-Get-Intl.log"
    dism.exe /image:"$MountPath" /Get-Intl /LogPath:"$CurrentLog"
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}