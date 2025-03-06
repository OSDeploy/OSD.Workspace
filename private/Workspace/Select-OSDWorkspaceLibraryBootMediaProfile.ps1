function Select-OSDWorkspaceLibraryBootMediaProfile {
    [CmdletBinding()]
    param ()
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
    $Error.Clear()
    #=================================================
    $LibraryItems = Get-OSDWorkspaceLibraryBootMediaProfile

    if ($LibraryItems) {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Select a BootMedia Profile to build this BootImage (Cancel to create a new BootMedia Profile)"
        $LibraryItems = $LibraryItems | Out-GridView -OutputMode Single -Title 'Select a BootMedia Profile to build this BootImage (Cancel to create a new BootMedia Profile)'
    
        $LibraryItems
    }
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}