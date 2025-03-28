function Step-BuildMediaWinPEMediaScript {
    [CmdletBinding()]
    param (
        $WinPEMediaScript = $global:BuildMedia.WinPEMediaScript
    )
    #=================================================
    $Error.Clear()
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] WinPEMediaScript: $WinPEMediaScript"
    #=================================================
    if ($WinPEMediaScript) {
        foreach ($Item in $WinPEMediaScript) {
            if (Test-Path $Item -ErrorAction SilentlyContinue) {
                Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Call WinPE Media Script [$Item]"
                & "$Item"
            }
            else {
                Write-Warning "BootMedia Script $Item (not found)"
            }
        }
    }
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}