function Step-BootImageRegCurrentVersionExport {
    [CmdletBinding()]
    param (
        [System.String]
        $MountPath = $global:BootMedia.MountPath,
        
        [System.String]
        $BootMediaCorePath = $global:BootMediaCorePath
    )
    #=================================================
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Export Get-RegCurrentVersion $BootMediaCorePath\pe-regcurrentversion.json"
    $RegKeyCurrentVersion = Get-RegCurrentVersion -Path $MountPath
    $RegKeyCurrentVersion | Out-File "$BootMediaCorePath\pe-regcurrentversion.txt"
    $RegKeyCurrentVersion | Export-Clixml -Path "$BootMediaCorePath\pe-regcurrentversion.xml"
    $RegKeyCurrentVersion | ConvertTo-Json | Out-File "$BootMediaCorePath\pe-regcurrentversion.json" -Encoding utf8 -Force
    $RegKeyCurrentVersion | Out-Host
    #=================================================
}