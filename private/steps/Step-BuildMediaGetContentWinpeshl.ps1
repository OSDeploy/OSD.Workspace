function Step-BuildMediaGetContentWinpeshl {
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
    if (Test-Path "$MountPath\Windows\System32\winpeshl.ini") {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] winpeshl.ini Content"
        [System.String]$ContentWinpeshl = Get-Content -Path "$MountPath\Windows\System32\winpeshl.ini" -Raw
        $global:BuildMedia.ContentWinpeshl = $ContentWinpeshl
        $global:BuildMedia.ContentWinpeshl | Out-Host
    }
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}