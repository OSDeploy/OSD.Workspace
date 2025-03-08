function Step-BootMediaLibraryBuildMediaScript {
    [CmdletBinding()]
    param (
        $BuildMediaScript = $global:BuildMedia.BuildMediaScript
    )
    if ($BuildMediaScript) {
        foreach ($Item in $BuildMediaScript) {
            if (Test-Path $Item -ErrorAction SilentlyContinue) {
                Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Call BootMedia Script [$Item]"
                & "$Item"
            }
            else {
                Write-Warning "BootMedia Script $Item (not found)"
            }
        }
    }
}