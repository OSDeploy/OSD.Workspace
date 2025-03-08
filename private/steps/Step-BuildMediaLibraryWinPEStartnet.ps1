function Step-BuildMediaLibraryWinPEStartnet {
    [CmdletBinding()]
    param (
        [System.String]
        $MountPath = $global:BuildMedia.MountPath,
        [System.String]
        $LibraryWinPEStartnet = $global:BuildMedia.LibraryWinPEStartnet
    )
    #=================================================
    $Error.Clear()
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] MountPath: $MountPath"
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] LibraryWinPEStartnet: $LibraryWinPEStartnet"
    #=================================================
    foreach ($Item in $LibraryWinPEStartnet) {
        if (Test-Path $Item) {
            Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Startnet.cmd: $Item"
            Copy-Item -Path $Item -Destination "$MountPath\Windows\System32\Startnet.cmd" -Force -Verbose
        }
        else {
            Write-Warning "BootImage Startnet $Item (not found)"
        }
    }
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}