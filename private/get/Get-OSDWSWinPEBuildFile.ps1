function Get-OSDWSWinPEBuildFile {
    <#
    .SYNOPSIS
        Returns available OSDWorkspace Library BootFile(s).

    .DESCRIPTION
        This function returns available OSDWorkspace Library and Library-GitHub BootFile(s).
        Utilizes the Get-OSDWSLibraryPath and Get-OSDWSLibraryRemotePath functions to retrieve the BootFile Path(s).

    .INPUTS
        None.

        You cannot pipe input to this cmdlet.

    .OUTPUTS
        System.Array

        This function returns the available boot files in the OSDWorkspace Library.

    .EXAMPLE
        Get-OSDWSWinPEBuildFile
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

    # Get the OSDWorkspace Library Subfolders
    $PrivateLibrary = Get-OSDWSLibraryPath
    foreach ($Subfolder in $PrivateLibrary) {
        $LibraryPaths += Get-ChildItem -Path $Subfolder -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName
    }

    # Get the OSDWorkspace Public Subfolders
    $PublicLibrary = Get-OSDWSLibraryRemotePath
    foreach ($Subfolder in $PublicLibrary) {
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
    
    $LibraryItems = $LibraryItems | Sort-Object -Property Type, Name

    $LibraryItems
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}