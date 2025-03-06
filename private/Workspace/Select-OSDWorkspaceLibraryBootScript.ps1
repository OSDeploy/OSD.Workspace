function Select-OSDWorkspaceLibraryBootScript {
        <#
    .SYNOPSIS
        Selects OSDWorkspace Library Boot Scripts.

    .DESCRIPTION
        This function displays available OSDWorkspace Library Boot Scripts in an Out-GridView and returns the selected scripts.
        Utilizes the Get-OSDWorkspaceLibraryBootScript function to retrieve the scripts.

    .INPUTS
        None.

        You cannot pipe input to this cmdlet.

    .OUTPUTS
        PSObject

        This function returns the selected Library Boot Scripts.

    .EXAMPLE
        Select-OSDWorkspaceLibraryBootScript
        Will display all available Library Boot Scripts and return the selected scripts.

    .NOTES
        David Segura
    #>
    [CmdletBinding()]
    param ()
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
    $Error.Clear()
    #=================================================
    $LibraryItems = Get-OSDWorkspaceLibraryBootScript

    if ($LibraryItems) {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Select BootImage and BootMedia Scripts to run during the build (Cancel to skip)"
        $LibraryItems = $LibraryItems | Out-GridView -PassThru -Title 'Select BootImage and BootMedia Scripts to run during the build (Cancel to skip)'
    
        return $LibraryItems
    }
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}