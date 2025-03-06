function Get-OSDWorkspaceLibraryBootFile {
    <#
    .SYNOPSIS
        Returns available OSDWorkspace Library BootFile(s).

    .DESCRIPTION
        This function returns available OSDWorkspace Library and Library-GitHub BootFile(s).
        Utilizes the Get-OSDWorkspaceLibraryPath and Get-OSDWorkspaceGitHubPath functions to retrieve the BootFile Path(s).

    .INPUTS
        None.

        You cannot pipe input to this cmdlet.

    .OUTPUTS
        System.Array

        This function returns the available boot files in the OSDWorkspace Library.

    .EXAMPLE
        Get-OSDWorkspaceLibraryBootFile
        Returns the boot files in the OSDWorkspace Library.

    .NOTES
        David Segura
    #>
    [CmdletBinding()]
    param ()
    #=================================================
    $Error.Clear()
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
    #=================================================
    $LibraryPaths = @()
    $LibraryPaths += Get-OSDWorkspaceLibraryPath

    $LibraryGitPaths = Get-OSDWorkspaceGitHubPath
    foreach ($LibraryGitPath in $LibraryGitPaths) {
        $LibraryPaths += Get-ChildItem -Path $LibraryGitPath -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName
    }
    
    $LibraryItems = @()
    $LibraryItems = foreach ($LibraryPath in $LibraryPaths) {
        Get-ChildItem -Path @("$LibraryPath\BootImage-File\*") -ErrorAction SilentlyContinue | `
            Where-Object { $_.PSIsContainer -eq $true } | `
            Select-Object @{Name = 'Phase'; Expression = { 'BootImage-File' } },
        Name, @{Name = 'Size'; Expression = { '' } }, LastWriteTime, FullName

        Get-ChildItem -Path @("$LibraryPath\BootImage-File\*.zip") -File -ErrorAction SilentlyContinue | `
            Select-Object @{Name = 'Phase'; Expression = { 'BootImage-File' } },
        Name, @{Name = 'Size'; Expression = { '{0:N2} MB' -f ($_.Length / 1MB) } }, LastWriteTime, FullName

        Get-ChildItem -Path @("$LibraryPath\BootMedia-File\*") -ErrorAction SilentlyContinue | `
            Where-Object { $_.PSIsContainer -eq $true } | `
            Select-Object @{Name = 'Phase'; Expression = { 'BootMedia-File' } },
        Name, @{Name = 'Size'; Expression = { '' } }, LastWriteTime, FullName

        Get-ChildItem -Path @("$LibraryPath\BootMedia-File\*.zip") -File -ErrorAction SilentlyContinue | `
            Select-Object @{Name = 'Phase'; Expression = { 'BootMedia-File' } },
        Name, @{Name = 'Size'; Expression = { '{0:N2} MB' -f ($_.Length / 1MB) } }, LastWriteTime, FullName
    }
    
    $LibraryItems = $LibraryItems | Sort-Object -Property Phase, Name

    $LibraryItems
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}