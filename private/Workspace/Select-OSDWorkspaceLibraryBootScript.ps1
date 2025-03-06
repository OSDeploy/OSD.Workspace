function Select-OSDWorkspaceLibraryBootScript {
    [CmdletBinding()]
    param ()
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
    $Error.Clear()
    #=================================================
    $LibraryItems = Get-OSDWorkspaceLibraryBootScript

    if ($LibraryItems) {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Select BootImage and BootMedia Scripts to run during the build (Cancel to skip)"
        $LibraryItems = $LibraryItems | Out-GridView -PassThru -Title 'Select BootImage and BootMedia Scripts to run during the build (Cancel to skip)'
    
        return $LibraryItems
    }
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}