function Select-OSDWorkspaceGitHubRepo {
    [CmdletBinding()]
    [OutputType([System.IO.FileSystemInfo])]
    param ()
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
    $Error.Clear()
    #=================================================
    $OSDWorkspaceGitRepository = Get-OSDWorkspaceGitHubRepo | Select-Object -Property Name, FullName | Sort-Object -Property Name, FullName

    if ($OSDWorkspaceGitRepository) {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Select an OSDWorkspace Repository (Cancel to skip)"
        $OSDWorkspaceGitRepository = $OSDWorkspaceGitRepository | Out-GridView -PassThru -Title 'Select an OSDWorkspace Repository (Cancel to skip)'
    
        $OSDWorkspaceGitRepository
    }
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}