function Step-BootMediaLibraryBootMediaScript {
    [CmdletBinding()]
    param (
        $BootMediaScript = $global:BuildMedia.BootMediaScript
    )
    if ($BootMediaScript) {
        foreach ($Item in $BootMediaScript) {
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