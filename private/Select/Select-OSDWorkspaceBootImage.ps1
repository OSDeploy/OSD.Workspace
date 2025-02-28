function Select-OSDWorkspaceBootImage {
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

    $BootImage = Get-OSDWorkspaceBootImage

    if ($Architecture) {
        $BootImage = $BootImage | Where-Object { $_.Architecture -eq $Architecture }
    }

    if ($BootImage) {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Select a BootImage and press OK (Cancel to skip)"
        $BootImage = $BootImage | Out-GridView -Title 'Select a BootImage and press OK (Cancel to skip)' -OutputMode Single
    }
    $BootImage
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}