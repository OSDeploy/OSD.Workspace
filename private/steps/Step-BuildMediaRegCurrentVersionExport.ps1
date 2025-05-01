function Step-BuildMediaRegCurrentVersionExport {
    [CmdletBinding()]
    param (
        [System.String]
        $MountPath = $global:BuildMedia.MountPath,
        [System.String]
        $BuildMediaCorePath = $global:BuildMediaCorePath
    )
    #=================================================
    $Error.Clear()
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Start"
    #=================================================
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] MountPath: $MountPath"
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] BuildMediaCorePath: $BuildMediaCorePath"
    #=================================================
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Export Get-RegCurrentVersion $BuildMediaCorePath\winpe-regcurrentversion.json"
    $RegKeyCurrentVersion = Get-RegCurrentVersion -Path $MountPath
    $RegKeyCurrentVersion | Out-File "$BuildMediaCorePath\winpe-regcurrentversion.txt"
    $RegKeyCurrentVersion | Export-Clixml -Path "$BuildMediaCorePath\winpe-regcurrentversion.xml"
    $RegKeyCurrentVersion | ConvertTo-Json -Depth 5 | Out-File "$BuildMediaCorePath\winpe-regcurrentversion.json" -Encoding utf8 -Force
    $RegKeyCurrentVersion | Out-Host
    #=================================================
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}