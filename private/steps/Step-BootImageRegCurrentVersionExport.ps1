function Step-BootImageRegCurrentVersionExport {
    [CmdletBinding()]
    param (
        [System.String]
        $MountPath = $global:BuildMedia.MountPath,
        
        [System.String]
        $BuildMediaCorePath = $global:BuildMediaCorePath
    )
    #=================================================
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Export Get-RegCurrentVersion $BuildMediaCorePath\winpe-regcurrentversion.json"
    $RegKeyCurrentVersion = Get-RegCurrentVersion -Path $MountPath
    $RegKeyCurrentVersion | Out-File "$BuildMediaCorePath\winpe-regcurrentversion.txt"
    $RegKeyCurrentVersion | Export-Clixml -Path "$BuildMediaCorePath\winpe-regcurrentversion.xml"
    $RegKeyCurrentVersion | ConvertTo-Json | Out-File "$BuildMediaCorePath\winpe-regcurrentversion.json" -Encoding utf8 -Force
    $RegKeyCurrentVersion | Out-Host
    #=================================================
}