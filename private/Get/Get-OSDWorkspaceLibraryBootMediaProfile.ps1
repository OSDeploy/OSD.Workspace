function Get-OSDWorkspaceLibraryBootMediaProfile {
    <#
    .SYNOPSIS
        Returns available OSDWorkspace Library BootMediaProfile(s).

    .DESCRIPTION
        This function returns available OSDWorkspace Library and Library-GitHub BootMediaProfile(s).
        Utilizes the Get-OSDWorkspaceLibraryPath and Get-OSDWorkspaceGitHubPath functions to retrieve the BootMediaProfile Path(s).

    .INPUTS
        None.

        You cannot pipe input to this cmdlet.

    .OUTPUTS
        System.Array

        This function returns the available boot media profiles in the OSDWorkspace Library.

    .EXAMPLE
        Get-OSDWorkspaceLibraryBootMediaProfile
        Returns the boot media profiles in the OSDWorkspace Library.

    .NOTES
        David Segura
    #>
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
        Get-ChildItem -Path @("$LibraryPath\BootMedia-Profile\*") -ErrorAction SilentlyContinue | `
            Where-Object { $_.Extension -eq '.json' } | `
            Select-Object @{Name = 'Phase'; Expression = { 'BootMedia-Profile' } },
        Name, @{Name = 'Size'; Expression = { '{0:N2} KB' -f ($_.Length / 1KB) } }, LastWriteTime, FullName
    }

    $LibraryItems = $LibraryItems | Sort-Object -Property LastWriteTime -Descending
    #TODO Need to Write when using so we know when it was last used

    $LibraryItems
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}