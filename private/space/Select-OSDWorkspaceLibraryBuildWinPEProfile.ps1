function Select-OSDWorkspaceLibraryBuildWinPEProfile {
        <#
    .SYNOPSIS
        Selects an OSDWorkspace Library BootMedia Profile.

    .DESCRIPTION
        This function displays available OSDWorkspace Library BootMedia Profiles in an Out-GridView and returns the selected BootMedia Profile object.
        Utilizes the Get-OSDWorkspaceLibraryBuildWinPEProfile function to retrieve the BootMedia Profiles.

    .INPUTS
        None.

        You cannot pipe input to this cmdlet.

    .OUTPUTS
        PSObject

        This function returns the selected BootMedia Profile object.

    .EXAMPLE
        Select-OSDWorkspaceLibraryBuildWinPEProfile
        Will display all available BootMedia Profiles and return the selected BootMedia Profile object.

    .NOTES
        David Segura
    #>
    [CmdletBinding()]
    param ()
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
    $Error.Clear()
    #=================================================
    $LibraryItems = Get-OSDWorkspaceLibraryBuildWinPEProfile

    if ($LibraryItems) {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Select a BootMedia Profile to build this BootImage (Cancel to create a new BootMedia Profile)"
        $LibraryItems = $LibraryItems | Out-GridView -OutputMode Single -Title 'Select a BootMedia Profile to build this BootImage (Cancel to create a new BootMedia Profile)'
    
        $LibraryItems
    }
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}