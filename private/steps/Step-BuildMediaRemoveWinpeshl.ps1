function Step-BuildMediaRemoveWinpeshl {
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
    $Winpeshl = "$MountPath\Windows\System32\winpeshl.ini"
    if (Test-Path $Winpeshl) {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Removing WinRE $Winpeshl"
        Remove-Item -Path $Winpeshl -Force
    }
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}