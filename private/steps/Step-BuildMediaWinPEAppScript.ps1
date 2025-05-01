function Step-BuildMediaWinPEAppScript {
    [CmdletBinding()]
    param (
        [System.String]
        $MountPath = $global:BuildMedia.MountPath,
        $WinPEAppScript = $global:BuildMedia.WinPEAppScript
    )
    #=================================================
    $Error.Clear()
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Start"
    #=================================================
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] MountPath: $MountPath"
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] WinPEAppScript: $WinPEAppScript"
    #=================================================
    foreach ($Item in $WinPEAppScript) {
        if (Test-Path $Item) {
            Write-Host -ForegroundColor DarkCyan "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] winpe-app: $Item"
            & "$Item"
        }
        else {
            Write-Warning "BootImage App $Item (not found)"
        }
    }
    #=================================================
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}