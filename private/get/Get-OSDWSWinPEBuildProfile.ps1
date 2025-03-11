function Get-OSDWSWinPEBuildProfile {
    <#
    .SYNOPSIS
        Returns available OSDWorkspace Library BuildProfile(s).

    .DESCRIPTION
        This function returns available OSDWorkspace Library and Library-GitHub BuildProfile(s).
        Utilizes the Get-OSDWSLibraryPath and Get-OSDWSLibraryRemotePath functions to retrieve the BuildProfile Path(s).

    .INPUTS
        None.

        You cannot pipe input to this cmdlet.

    .OUTPUTS
        System.Array

        This function returns the available boot media profiles in the OSDWorkspace Library.

    .EXAMPLE
        Get-OSDWSWinPEBuildProfile
        Returns the boot media profiles in the OSDWorkspace Library.

    .NOTES
        David Segura
    #>
    [CmdletBinding()]
    param ()
    #=================================================
    $Error.Clear()
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
    #=================================================
    $LibraryPath = Get-OSDWSWinPEBuildProfilePath

    $LibraryItems = Get-ChildItem -Path @("$LibraryPath\*") -ErrorAction SilentlyContinue | `
        Where-Object { $_.Extension -eq '.json' } | `
        Select-Object @{Name = 'Type'; Expression = { 'WinPE-BuildProfile' } },
        Name, @{Name = 'Size'; Expression = { '{0:N2} KB' -f ($_.Length / 1KB) } }, LastWriteTime, FullName

    $LibraryItems = $LibraryItems | Sort-Object -Property LastWriteTime -Descending
    #TODO Need to Write when using so we know when it was last used

    $LibraryItems
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}