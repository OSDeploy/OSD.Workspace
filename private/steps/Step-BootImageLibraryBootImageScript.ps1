function Step-BootImageLibraryBootImageScript {
    [CmdletBinding()]
    param (
        [System.String]
        $MountPath = $global:BuildMedia.MountPath,

        $BootImageScript = $global:BuildMedia.BootImageScript
    )
    foreach ($Item in $BootImageScript) {
        if (Test-Path $Item) {
            Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] BootImage-Script: $Item"
            & "$Item"
        }
        else {
            Write-Warning "BootImage Script $Item (not found)"
        }
    }
}