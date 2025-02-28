function Select-OSDWorkspaceLibraryBootFile {
    [CmdletBinding()]
    param ()
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
    $Error.Clear()
    #=================================================
    $LibraryItems = Get-OSDWorkspaceLibraryBootFile

    if ($LibraryItems) {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Select BootImage and BootMedia Files to add to the build (Cancel to skip)"
        $LibraryItems = $LibraryItems | Out-GridView -PassThru -Title 'Select BootImage and BootMedia Files to add to the build (Cancel to skip)'
    
        $LibraryItems
    }
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}