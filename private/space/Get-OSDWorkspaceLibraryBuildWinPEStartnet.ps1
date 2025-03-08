function Get-OSDWorkspaceLibraryBuildWinPEStartnet {
        <#
    .SYNOPSIS
        Returns available OSDWorkspace Library BuildWinPEStartnet(s).

    .DESCRIPTION
        This function returns available OSDWorkspace Library and Library-GitHub BuildWinPEStartnet(s).
        Utilizes the Get-OSDWorkspaceLibraryPath and Get-OSDWorkspaceGitHubPath functions to retrieve the BuildWinPEStartnet Path(s).

    .INPUTS
        None.

        You cannot pipe input to this cmdlet.

    .OUTPUTS
        System.Array

        This function returns the available boot startnet scripts in the OSDWorkspace Library.

    .EXAMPLE
        Get-OSDWorkspaceLibraryBuildWinPEStartnet
        Returns the boot startnet scripts in the OSDWorkspace Library.

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
        Get-ChildItem -Path @("$LibraryPath\Build-WinPEStartnet\*") -ErrorAction SilentlyContinue | `
            Where-Object { $_.Extension -eq '.cmd' } | `
            Select-Object @{Name = 'Phase'; Expression = { 'Build-WinPEStartnet' } },
        Name, @{Name = 'Content'; Expression = { (Get-Content $_ -Raw) } },
        @{Name = 'Size'; Expression = { '{0:N2} KB' -f ($_.Length / 1KB) } }, LastWriteTime, FullName
    }

    $LibraryItems = $LibraryItems | Sort-Object -Property Phase, Name, FullName

    $LibraryItems
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}