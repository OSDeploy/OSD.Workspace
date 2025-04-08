function Step-WinPEAppOpenSSH {
    [CmdletBinding()]
    param (
        [System.String]
        $AppName = 'OpenSSH',

        [System.String]
        $MountPath = $global:BuildMedia.MountPath
    )
    #=================================================
    $Error.Clear()
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Start"
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] MountPath: $MountPath"
    #=================================================
    # WinRE Add WirelessConnect.exe
    if (Test-Path "$MountPath\Windows\System32\OpenSSH\ssh.exe") {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] OpenSSH: OpenSSH is already installed."
        
        # Record the installed app
        $global:BuildMedia.InstalledApps += $AppName
    }
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}