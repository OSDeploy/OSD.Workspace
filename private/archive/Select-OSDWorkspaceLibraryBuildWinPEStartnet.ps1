function Select-OSDWorkspaceLibraryWinPEStartnet {
    [CmdletBinding()]
    param ()
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
    $Error.Clear()
    #=================================================
    $LibraryItems = Get-OSDWorkspaceLibraryWinPEStartnet

    if ($LibraryItems) {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Select a Startnet.cmd to add to this BootImage (Cancel to skip)"
        $LibraryItems = $LibraryItems | Out-GridView -OutputMode Single -Title 'Select a Startnet.cmd to add to this BootImage (Cancel to skip)'
    
        $LibraryItems
    }
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}