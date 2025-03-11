function Select-OSDWSRemoteLibrary {
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
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
    #=================================================
    $results = Get-OSDWSRemoteLibrary | Select-Object -Property Name, FullName | Sort-Object -Property Name, FullName

    if ($results) {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Select an OSDWorkspace Repository (Cancel to skip)"
        $results = $results | Out-GridView -PassThru -Title 'Select an OSDWorkspace Repository (Cancel to skip)'
    
        return $results
    }
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}