function Step-BootImageWindowsImageExport {
    [CmdletBinding()]
    param (
        [System.String]
        $BuildMediaSourcesPath = $global:BuildMediaSourcesPath,
        [System.String]
        $BuildMediaSourcesPathEX = $global:BuildMediaSourcesPathEX,
        [System.String]
        $BootMediaCorePath = $global:BootMediaCorePath,
        [System.String]
        $BootMediaLogs = $global:BootMediaLogs,
        [System.String]
        $WimSourceType = $global:BootMedia.WimSourceType
    )
    #=================================================
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Export-WindowsImage"
    $BuildMediaSourcesPathBootWim = Join-Path $BuildMediaSourcesPath 'boot.wim'
    $BuildMediaSourcesPathExportWim = Join-Path $BuildMediaSourcesPath 'export.wim'
    if (Test-Path $BuildMediaSourcesPathExportWim) {
        Remove-Item -Path $BuildMediaSourcesPathExportWim -Force -ErrorAction Stop | Out-Null
    }
    $CurrentLog = "$BootMediaLogs\$((Get-Date).ToString('yyMMdd-HHmmss'))-Export-windowsimage.log"
    if ($WimSourceType -eq 'WinPE') {
        Export-WindowsImage -SourceImagePath $BuildMediaSourcesPathBootWim -SourceIndex 1 -DestinationImagePath $BuildMediaSourcesPathExportWim -LogPath $CurrentLog | Out-Null
    }
    else {
        # Export-WindowsImage -SourceImagePath $BuildMediaSourcesPathBootWim -SourceIndex 1 -DestinationImagePath $BuildMediaSourcesPathExportWim -DestinationName 'Microsoft Windows PE (x64)' -LogPath $CurrentLog | Out-Null
        Export-WindowsImage -SourceImagePath $BuildMediaSourcesPathBootWim -SourceIndex 1 -DestinationImagePath $BuildMediaSourcesPathExportWim -LogPath $CurrentLog | Out-Null
    }
    Remove-Item -Path $BuildMediaSourcesPathBootWim -Force -ErrorAction Stop | Out-Null
    Rename-Item -Path $BuildMediaSourcesPathExportWim -NewName 'boot.wim' -Force -ErrorAction Stop | Out-Null

    Get-WindowsImage -ImagePath $BuildMediaSourcesPathBootWim -Index 1 | Export-Clixml -Path "$BootMediaCorePath\pe-windowsimage.xml"
    Get-WindowsImage -ImagePath $BuildMediaSourcesPathBootWim -Index 1 | ConvertTo-Json | Out-File "$BootMediaCorePath\pe-windowsimage.json" -Encoding utf8

    Copy-Item -Path $(Join-Path $BuildMediaSourcesPath 'boot.wim') -Destination $(Join-Path $BuildMediaSourcesPathEX 'boot.wim') -Force -ErrorAction Stop | Out-Null
    #=================================================
}