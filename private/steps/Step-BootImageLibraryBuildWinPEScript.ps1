function Step-BootImageLibraryBuildWinPEScript {
    [CmdletBinding()]
    param (
        [System.String]
        $MountPath = $global:BuildMedia.MountPath,

        $BuildWinPEScript = $global:BuildMedia.BuildWinPEScript
    )
    foreach ($Item in $BuildWinPEScript) {
        if (Test-Path $Item) {
            Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] WinPE-Script: $Item"
            & "$Item"
        }
        else {
            Write-Warning "BootImage Script $Item (not found)"
        }
    }
}