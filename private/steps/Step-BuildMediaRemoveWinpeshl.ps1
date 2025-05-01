function Step-BuildMediaRemoveWinpeshl {
    [CmdletBinding()]
    param (
        [System.String]
        $MountPath = $global:BuildMedia.MountPath
    )
    #=================================================
    $Error.Clear()
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Start"
    #=================================================
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] MountPath: $MountPath"
    #=================================================
    $Winpeshl = "$MountPath\Windows\System32\winpeshl.ini"
    if (Test-Path $Winpeshl) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Removing WinRE $Winpeshl"
        Remove-Item -Path $Winpeshl -Force
    }
    #=================================================
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}