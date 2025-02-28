function Get-OSDWorkspaceLibraryBootScript {
    [CmdletBinding()]
    param ()
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
    $Error.Clear()
    #=================================================
    $LibraryPaths = @()
    $LibraryPaths += Get-OSDWorkspaceLibraryPath

    $LibraryGitPaths = Get-OSDWorkspaceGitHubPath
    foreach ($LibraryGitPath in $LibraryGitPaths) {
        $LibraryPaths += Get-ChildItem -Path $LibraryGitPath -Directory -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName
    }
    
    $LibraryItems = @()
    $LibraryItems = foreach ($LibraryPath in $LibraryPaths) {
        Get-ChildItem -Path @("$LibraryPath\BootImage-Script") -Recurse -ErrorAction SilentlyContinue | `
            Where-Object { $_.Extension -eq '.ps1' } | `
            Select-Object @{Name = 'Phase'; Expression = { 'BootImage-Script' } },
        Name, @{Name = 'Size'; Expression = { '{0:N2} KB' -f ($_.Length / 1KB) } }, LastWriteTime, FullName
            
        Get-ChildItem -Path @("$LibraryPath\BootMedia-Script") -Recurse -ErrorAction SilentlyContinue | `
            Where-Object { $_.Extension -eq '.ps1' } | `
            Select-Object @{Name = 'Phase'; Expression = { 'BootMedia-Script' } },
        Name, @{Name = 'Size'; Expression = { '{0:N2} KB' -f ($_.Length / 1KB) } }, LastWriteTime, FullName
    }

    $LibraryItems = $LibraryItems | Sort-Object -Property Phase, Name

    $LibraryItems
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}