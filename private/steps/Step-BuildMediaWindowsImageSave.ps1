function Step-BuildMediaWindowsImageSave {
    [CmdletBinding()]
    param (
        $WindowsImage = $global:WindowsImage,
        $LogsPath = $global:BuildMediaLogsPath
    )
    #=================================================
    $Error.Clear()
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Start"
    #=================================================
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] WindowsImage: $WindowsImage"
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] LogsPath: $LogsPath"
    #=================================================
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Save Windows Image"
    $CurrentLog = "$LogsPath\$((Get-Date).ToString('yyMMdd-HHmmss'))-Save-WindowsImage.log"
    $WindowsImage | Save-WindowsImage -LogPath $CurrentLog | Out-Null
    #=================================================
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}