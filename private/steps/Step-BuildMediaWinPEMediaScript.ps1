function Step-BuildMediaWinPEMediaScript {
    [CmdletBinding()]
    param (
        $WinPEMediaScript = $global:BuildMedia.WinPEMediaScript
    )
    #=================================================
    $Error.Clear()
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Start"
    #=================================================
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] WinPEMediaScript: $WinPEMediaScript"
    #=================================================
    if ($WinPEMediaScript) {
        foreach ($Item in $WinPEMediaScript) {
            if (Test-Path $Item -ErrorAction SilentlyContinue) {
                Write-Host -ForegroundColor DarkCyan "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Call WinPE Media Script [$Item]"
                & "$Item"
            }
            else {
                Write-Warning "BootMedia Script $Item (not found)"
            }
        }
    }
    #=================================================
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}