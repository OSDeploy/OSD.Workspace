function Get-OSDWSWinPEBuildFile {
    <#
    .SYNOPSIS
        Returns available OSDWorkspace Library BootFile(s).

    .NOTES
        David Segura
    #>
    [CmdletBinding()]
    param ()
    #=================================================
    $Error.Clear()
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Start"
    #=================================================
    $LibraryPaths = @()

    # Get the OSDWorkspace Library Subfolders
    $LibraryLocal = $OSDWorkspace.paths.library_local
    foreach ($Subfolder in $LibraryLocal) {
        $LibraryPaths += Get-ChildItem -Path $Subfolder -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName
    }

    # Get the OSDWorkspace Public Subfolders
    $LibraryShared = $OSDWorkspace.paths.library_submodule
    foreach ($Subfolder in $LibraryShared) {
        $LibraryPaths += Get-ChildItem -Path $Subfolder -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName
    }
    
    $LibraryItems = @()
    $LibraryItems = foreach ($LibraryPath in $LibraryPaths) {
        Get-ChildItem -Path @("$LibraryPath\WinPE-File\*") -ErrorAction SilentlyContinue | `
            Where-Object { $_.PSIsContainer -eq $true } | `
            Select-Object @{Name = 'Type'; Expression = { 'WinPE-File' } },
        Name, @{Name = 'Size'; Expression = { '' } }, LastWriteTime, FullName

        Get-ChildItem -Path @("$LibraryPath\WinPE-File\*.zip") -File -ErrorAction SilentlyContinue | `
            Select-Object @{Name = 'Type'; Expression = { 'WinPE-File' } },
        Name, @{Name = 'Size'; Expression = { '{0:N2} MB' -f ($_.Length / 1MB) } }, LastWriteTime, FullName

        Get-ChildItem -Path @("$LibraryPath\WinPE-MediaFile\*") -ErrorAction SilentlyContinue | `
            Where-Object { $_.PSIsContainer -eq $true } | `
            Select-Object @{Name = 'Type'; Expression = { 'WinPE-MediaFile' } },
        Name, @{Name = 'Size'; Expression = { '' } }, LastWriteTime, FullName

        Get-ChildItem -Path @("$LibraryPath\WinPE-MediaFile\*.zip") -File -ErrorAction SilentlyContinue | `
            Select-Object @{Name = 'Type'; Expression = { 'WinPE-MediaFile' } },
        Name, @{Name = 'Size'; Expression = { '{0:N2} MB' -f ($_.Length / 1MB) } }, LastWriteTime, FullName
    }
    
    $LibraryItems = $LibraryItems | Sort-Object -Property Name, FullName

    $LibraryItems
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}