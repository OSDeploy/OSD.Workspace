function Get-OSDWSWinPEBuildScript {
    <#
    .SYNOPSIS
        Returns available OSDWorkspace Library BootScript(s).

    .NOTES
        David Segura
    #>
    [CmdletBinding()]
    param ()
    #=================================================
    $Error.Clear()
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Start"
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
        Get-ChildItem -Path @("$LibraryPath\winpe-apps\*\*") -ErrorAction SilentlyContinue | `
            Where-Object { $_.Extension -eq '.ps1' } | `
            Select-Object @{Name = 'Type'; Expression = { 'winpe-appscript' } },
            @{Name = 'Library'; Expression = { (Split-Path -Path $LibraryPath -Leaf) } },
            Name, @{Name = 'Size'; Expression = { '{0:N2} KB' -f ($_.Length / 1KB) } }, LastWriteTime, FullName

        Get-ChildItem -Path @("$LibraryPath\winpe-script\*\*") -ErrorAction SilentlyContinue | `
            Where-Object { $_.Extension -eq '.ps1' } | `
            Select-Object @{Name = 'Type'; Expression = { 'winpe-script' } },
            @{Name = 'Library'; Expression = { (Split-Path -Path $LibraryPath -Leaf) } },
            Name, @{Name = 'Size'; Expression = { '{0:N2} KB' -f ($_.Length / 1KB) } }, LastWriteTime, FullName
            
        Get-ChildItem -Path @("$LibraryPath\winpe-mediascript\*\*") -ErrorAction SilentlyContinue | `
            Where-Object { $_.Extension -eq '.ps1' } | `
            Select-Object @{Name = 'Type'; Expression = { 'winpe-mediascript' } },
            @{Name = 'Library'; Expression = { (Split-Path -Path $LibraryPath -Leaf) } },
            Name, @{Name = 'Size'; Expression = { '{0:N2} KB' -f ($_.Length / 1KB) } }, LastWriteTime, FullName
    }

    $LibraryItems = $LibraryItems | Sort-Object -Property FullName

    $LibraryItems
    #=================================================
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}