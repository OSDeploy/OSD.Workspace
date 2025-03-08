function Step-BuildMediaGetContentStartnet {
    [CmdletBinding()]
    param (
        [System.String]
        $MountPath = $global:BuildMedia.MountPath
    )
    #=================================================
    $Error.Clear()
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] MountPath: $MountPath"
    #=================================================
    if (Test-Path "$MountPath\Windows\System32\startnet.cmd") {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Startnet.cmd Content"
        [System.String]$ContentStartnet = Get-Content -Path "$MountPath\Windows\System32\startnet.cmd" -Raw
        $global:BuildMedia.ContentStartnet = $ContentStartnet
        $global:BuildMedia.ContentStartnet | Out-Host
    }
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}