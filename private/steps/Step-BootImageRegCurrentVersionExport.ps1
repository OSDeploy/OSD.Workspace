function Step-BootImageRegCurrentVersionExport {
    [CmdletBinding()]
    param (
        [System.String]
        $MountPath = $global:BootMedia.MountPath,
        
        [System.String]
        $BootMediaCorePath = $global:BootMediaCorePath
    )
    #=================================================
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Export Get-RegCurrentVersion $BootMediaCorePath\pe-RegCurrentVersion.json"
    $RegKeyCurrentVersion = Get-RegCurrentVersion -Path $MountPath
    $RegKeyCurrentVersion | Out-File "$BootMediaCorePath\pe-RegCurrentVersion.txt"
    $RegKeyCurrentVersion | Export-Clixml -Path "$BootMediaCorePath\pe-RegCurrentVersion.xml"
    $RegKeyCurrentVersion | ConvertTo-Json | Out-File "$BootMediaCorePath\pe-RegCurrentVersion.json" -Encoding utf8 -Force
    $RegKeyCurrentVersion | Out-Host
    #=================================================
}