function Step-BootImageExportWindowsDriverPE {
    [CmdletBinding()]
    param (
        $WindowsImage = $global:WindowsImage,
        [System.String]
        $BootMediaCorePath = $global:BootMediaCorePath
    )
    #=================================================
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Export Get-WindowsDriver $BootMediaCorePath\pe-windowsdriver.json"
    $WindowsDriver = $WindowsImage | Get-WindowsDriver
    if ($WindowsDriver) {
        $WindowsDriver | Select-Object * | Export-Clixml -Path "$BootMediaCorePath\pe-windowsdriver.xml" -Force
        $WindowsDriver | ConvertTo-Json | Out-File "$BootMediaCorePath\pe-windowsdriver.json" -Encoding utf8 -Force
        $WindowsDriver | Sort-Object ProviderName, CatalogFile, Version | Select-Object ProviderName, CatalogFile, Version, Date, ClassName, BootCritical, Driver, @{ Name = 'FileRepository'; Expression = { ($_.OriginalFileName.split('\')[-2]) } } | Format-Table -AutoSize
    }
    #=================================================
}