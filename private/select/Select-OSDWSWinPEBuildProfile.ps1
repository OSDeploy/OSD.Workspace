function Select-OSDWSWinPEBuildProfile {
        <#
    .SYNOPSIS
        Selects an OSDWorkspace Library BootMedia Profile.

    .DESCRIPTION
        This function displays available OSDWorkspace Library BootMedia Profiles in an Out-GridView and returns the selected BootMedia Profile object.
        Utilizes the Get-OSDWSWinPEBuildProfile function to retrieve the BootMedia Profiles.

    .INPUTS
        None.

        You cannot pipe input to this cmdlet.

    .OUTPUTS
        PSObject

        This function returns the selected BootMedia Profile object.

    .EXAMPLE
        Select-OSDWSWinPEBuildProfile
        Will display all available BootMedia Profiles and return the selected BootMedia Profile object.

    .NOTES
        David Segura
    #>
    [CmdletBinding()]
    param ()
    #=================================================
    $Error.Clear()
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
    #=================================================
    $results = Get-OSDWSWinPEBuildProfile

    if ($results) {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Select a BootMedia Profile to build this BootImage (Cancel to create a new BootMedia Profile)"
        $results = $results | Out-GridView -OutputMode Single -Title 'Select a BootMedia Profile to build this BootImage (Cancel to create a new BootMedia Profile)'
    
        return $results
    }
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}