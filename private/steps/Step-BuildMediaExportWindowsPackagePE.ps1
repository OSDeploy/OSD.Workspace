function Step-BuildMediaExportWindowsPackagePE {
    [CmdletBinding()]
    param (
        $WindowsImage = $global:WindowsImage,
        [System.String]
        $BuildMediaCorePath = $global:BuildMediaCorePath
    )
    #=================================================
    $Error.Clear()
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Start"
    #=================================================
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] WindowsImage: $WindowsImage"
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] BuildMediaCorePath: $BuildMediaCorePath"
    #=================================================
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Export Get-WindowsPackage $BuildMediaCorePath\winpe-windowspackage.json"
    $WindowsPackage = $WindowsImage | Get-WindowsPackage
    if ($WindowsPackage) {
        $WindowsPackage | Select-Object * | Export-Clixml -Path "$BuildMediaCorePath\winpe-windowspackage.xml" -Force
        $WindowsPackage | ConvertTo-Json -Depth 5 | Out-File "$BuildMediaCorePath\winpe-windowspackage.json" -Encoding utf8 -Force
        $WindowsPackage | Sort-Object -Property PackageName | Format-Table -AutoSize
    }
    #=================================================
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}