function Step-BuildMediaDismSettings {
    [CmdletBinding()]
    param (
        [System.String]
        $MountPath = $global:BuildMedia.MountPath,
        [System.String]
        $LogsPath = $global:BuildMediaLogsPath,

        $SetTimeZone = $global:BuildMedia.SetTimeZone,
        $SetAllIntl = $global:BuildMedia.SetAllIntl,
        $SetInputLocale = $global:BuildMedia.SetInputLocale
    )
    #=================================================
    $Error.Clear()
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Start"
    #=================================================
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] MountPath: $MountPath"
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] LogsPath: $LogsPath"
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] SetAllIntl: $SetAllIntl"
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] SetInputLocale: $SetInputLocale"
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] SetTimeZone: $SetTimeZone"
    #=================================================
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Set-TimeZone to $SetTimeZone"
    $CurrentLog = "$LogsPath\$((Get-Date).ToString('yyMMdd-HHmmss'))-Set-TimeZone.log"
    dism.exe /quiet /image:"$MountPath" /Set-TimeZone:"$SetTimeZone" /LogPath:"$CurrentLog"

    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Log current Get-Intl configuration"
    $CurrentLog = "$LogsPath\$((Get-Date).ToString('yyMMdd-HHmmss'))-Get-Intl.log"
    dism.exe /quiet /image:"$MountPath" /Get-Intl /LogPath:"$CurrentLog"

    if ($SetAllIntl) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Set-AllIntl to $SetAllIntl"
        $CurrentLog = "$LogsPath\$((Get-Date).ToString('yyMMdd-HHmmss'))-Set-AllIntl.log"
        dism.exe /quiet /image:"$MountPath" /Set-AllIntl:$SetAllIntl /LogPath:"$CurrentLog"
    }

    if ($SetInputLocale) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Set-InputLocale to $SetInputLocale"
        $CurrentLog = "$LogsPath\$((Get-Date).ToString('yyMMdd-HHmmss'))-Set-InputLocale.log"
        dism.exe /quiet /image:"$MountPath" /Set-InputLocale:$SetInputLocale /LogPath:"$CurrentLog"
    }
    #=================================================
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}