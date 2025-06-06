function Select-OSDWSSharedLibrary {
    <#
    .SYNOPSIS
        Selects an OSDWorkspace Library GitHub Repository.
    .NOTES
        David Segura
    #>
    [CmdletBinding()]
    [OutputType([System.IO.FileSystemInfo])]
    param ()
    #=================================================
    $Error.Clear()
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Start"
    #=================================================
    $results = Get-OSDWSLibrarySubmodule | Select-Object -Property Name, FullName | Sort-Object -Property Name, FullName

    if ($results) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Select an OSDWorkspace Repository (Cancel to skip)"
        $results = $results | Out-GridView -PassThru -Title 'Select an OSDWorkspace Repository (Cancel to skip)'
    
        return $results
    }
    #=================================================
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}