function Get-OSDWSWinPEBuildProfile {
    <#
    .SYNOPSIS
        Returns available OSDWorkspace Library BuildProfile(s).

    .NOTES
        David Segura
    #>
    [CmdletBinding()]
    param ()
    #=================================================
    $Error.Clear()
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
    #=================================================
    $LibraryPath = $OSDWorkspace.paths.winpe_buildprofile

    $LibraryItems = Get-ChildItem -Path @("$LibraryPath\*") -ErrorAction SilentlyContinue | `
        Where-Object { $_.Extension -eq '.json' } | `
        Select-Object @{Name = 'Type'; Expression = { 'WinPE-BuildProfile' } },
        Name, @{Name = 'Size'; Expression = { '{0:N2} KB' -f ($_.Length / 1KB) } }, LastWriteTime, FullName

    $LibraryItems = $LibraryItems | Sort-Object -Property Name, FullName

    $LibraryItems
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}