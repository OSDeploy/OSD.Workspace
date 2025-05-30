function Step-BuildMediaWindowsImageExport {
    [CmdletBinding()]
    param (
        [System.String]
        $BuildMediaCorePath = $global:BuildMediaCorePath,
        [System.String]
        $BuildMediaSourcesPath = $global:BuildMediaSourcesPath,
        [System.String]
        $BuildMediaSourcesPathEX = $global:BuildMediaSourcesPathEX,
        [System.String]
        $LogsPath = $global:BuildMediaLogsPath,
        [System.String]
        $WimSourceType = $global:BuildMedia.WimSourceType
    )
    #=================================================
    $Error.Clear()
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Start"
    #=================================================
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] BuildMediaCorePath: $BuildMediaCorePath"
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] BuildMediaSourcesPath: $BuildMediaSourcesPath"
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] BuildMediaSourcesPathEX: $BuildMediaSourcesPathEX"
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] LogsPath: $LogsPath"
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] WimSourceType: $WimSourceType"
    #=================================================
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Export-WindowsImage"
    $BuildMediaSourcesPathBootWim = Join-Path $BuildMediaSourcesPath 'boot.wim'
    $BuildMediaSourcesPathExportWim = Join-Path $BuildMediaSourcesPath 'export.wim'
    if (Test-Path $BuildMediaSourcesPathExportWim) {
        Remove-Item -Path $BuildMediaSourcesPathExportWim -Force -ErrorAction Stop | Out-Null
    }
    $CurrentLog = "$LogsPath\$((Get-Date).ToString('yyMMdd-HHmmss'))-Export-windowsimage.log"
    if ($WimSourceType -eq 'WinPE') {
        Export-WindowsImage -SourceImagePath $BuildMediaSourcesPathBootWim -SourceIndex 1 -DestinationImagePath $BuildMediaSourcesPathExportWim -LogPath $CurrentLog | Out-Null
    }
    else {
        # Export-WindowsImage -SourceImagePath $BuildMediaSourcesPathBootWim -SourceIndex 1 -DestinationImagePath $BuildMediaSourcesPathExportWim -DestinationName 'Microsoft Windows PE (x64)' -LogPath $CurrentLog | Out-Null
        Export-WindowsImage -SourceImagePath $BuildMediaSourcesPathBootWim -SourceIndex 1 -DestinationImagePath $BuildMediaSourcesPathExportWim -LogPath $CurrentLog | Out-Null
    }
    Remove-Item -Path $BuildMediaSourcesPathBootWim -Force -ErrorAction Stop | Out-Null
    Rename-Item -Path $BuildMediaSourcesPathExportWim -NewName 'boot.wim' -Force -ErrorAction Stop | Out-Null

    Get-WindowsImage -ImagePath $BuildMediaSourcesPathBootWim -Index 1 | Export-Clixml -Path "$BuildMediaCorePath\winpe-windowsimage.xml"
    Get-WindowsImage -ImagePath $BuildMediaSourcesPathBootWim -Index 1 | ConvertTo-Json -Depth 5 | Out-File "$BuildMediaCorePath\winpe-windowsimage.json" -Encoding utf8 -Force

    if ($BuildMediaSourcesPathEX) {
        Copy-Item -Path $(Join-Path $BuildMediaSourcesPath 'boot.wim') -Destination $(Join-Path $BuildMediaSourcesPathEX 'boot.wim') -Force -ErrorAction Stop | Out-Null
    }
    #=================================================
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}