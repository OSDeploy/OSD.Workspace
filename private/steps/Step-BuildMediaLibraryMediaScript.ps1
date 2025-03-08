function Step-BuildMediaLibraryMediaScript {
    [CmdletBinding()]
    param (
        $LibraryMediaScript = $global:BuildMedia.LibraryMediaScript
    )
    #=================================================
    $Error.Clear()
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] LibraryMediaScript: $LibraryMediaScript"
    #=================================================
    if ($LibraryMediaScript) {
        foreach ($Item in $LibraryMediaScript) {
            if (Test-Path $Item -ErrorAction SilentlyContinue) {
                Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Call BootMedia Script [$Item]"
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