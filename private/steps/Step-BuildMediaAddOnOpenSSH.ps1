function Step-BuildMediaAddOnOpenSSH {
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
    # WinRE Add WirelessConnect.exe
    $global:BuildMedia.AddOnOpenSSH = $false
    if (Test-Path "$MountPath\Windows\System32\OpenSSH\ssh.exe") {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] OpenSSH: OpenSSH is already installed."
        $global:BuildMedia.AddOnOpenSSH = $true
    }
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}