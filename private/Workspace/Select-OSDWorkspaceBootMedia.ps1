function Select-OSDWorkspaceBootMedia {
    [CmdletBinding()]
    param (
        [ValidateSet('amd64', 'arm64')]
        [System.String]
        $Architecture
    )
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
    $Error.Clear()
    #=================================================

    $BootMedia = Get-OSDWorkspaceBootMedia

    if ($Architecture) {
        $BootMedia = $BootMedia | Where-Object { $_.Architecture -eq $Architecture }
    }

    if ($BootMedia) {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Select a BootMedia and press OK (Cancel to skip)"
        $BootMedia = $BootMedia | Out-GridView -Title 'Select a BootMedia and press OK (Cancel to skip)' -OutputMode Single
    }
    $BootMedia
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}