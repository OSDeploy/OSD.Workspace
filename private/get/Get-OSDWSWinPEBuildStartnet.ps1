function Get-OSDWSWinPEBuildStartnet {
        <#
    .SYNOPSIS
        Returns available OSDWorkspace Library LibraryWinPEStartnet(s).

    .DESCRIPTION
        This function returns available OSDWorkspace Library and Library-GitHub LibraryWinPEStartnet(s).
        Utilizes the Get-OSDWSLibraryPath and Get-OSDWSLibraryRemotePath functions to retrieve the LibraryWinPEStartnet Path(s).

    .INPUTS
        None.

        You cannot pipe input to this cmdlet.

    .OUTPUTS
        System.Array

        This function returns the available boot startnet scripts in the OSDWorkspace Library.

    .EXAMPLE
        Get-OSDWSWinPEBuildStartnet
        Returns the boot startnet scripts in the OSDWorkspace Library.

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
        Get-ChildItem -Path @("$LibraryPath\WinPE-Startnet\*") -ErrorAction SilentlyContinue | `
            Where-Object { $_.Extension -eq '.cmd' } | `
            Select-Object @{Name = 'Type'; Expression = { 'WinPE-Startnet' } },
        Name, @{Name = 'Content'; Expression = { (Get-Content $_ -Raw) } },
        @{Name = 'Size'; Expression = { '{0:N2} KB' -f ($_.Length / 1KB) } }, LastWriteTime, FullName
    }

    $LibraryItems = $LibraryItems | Sort-Object -Property Type, Name, FullName

    $LibraryItems
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}