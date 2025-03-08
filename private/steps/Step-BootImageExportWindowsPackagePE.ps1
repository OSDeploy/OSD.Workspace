function Step-BootImageExportWindowsPackagePE {
    [CmdletBinding()]
    param (
        $WindowsImage = $global:WindowsImage,
        [System.String]
        $BootMediaCorePath = $global:BootMediaCorePath
    )
    #=================================================
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Export Get-WindowsPackage $BootMediaCorePath\pe-windowspackage.json"
    $WindowsPackage = $WindowsImage | Get-WindowsPackage
    if ($WindowsPackage) {
        $WindowsPackage | Select-Object * | Export-Clixml -Path "$BootMediaCorePath\pe-windowspackage.xml" -Force
        $WindowsPackage | ConvertTo-Json | Out-File "$BootMediaCorePath\pe-windowspackage.json" -Encoding utf8 -Force
        $WindowsPackage | Sort-Object -Property PackageName | Format-Table -AutoSize
    }
    #=================================================
}