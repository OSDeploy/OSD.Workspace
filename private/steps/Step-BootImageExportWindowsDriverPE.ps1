function Step-BootImageExportWindowsDriverPE {
    [CmdletBinding()]
    param (
        $WindowsImage = $global:WindowsImage,
        [System.String]
        $BootMediaCorePath = $global:BootMediaCorePath
    )
    #=================================================
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Export Get-WindowsDriver $BootMediaCorePath\pe-WindowsDriver.json"
    $WindowsDriver = $WindowsImage | Get-WindowsDriver
    if ($WindowsDriver) {
        $WindowsDriver | Select-Object * | Export-Clixml -Path "$BootMediaCorePath\pe-WindowsDriver.xml" -Force
        $WindowsDriver | ConvertTo-Json | Out-File "$BootMediaCorePath\pe-WindowsDriver.json" -Encoding utf8 -Force
        $WindowsDriver | Sort-Object ProviderName, CatalogFile, Version | Select-Object ProviderName, CatalogFile, Version, Date, ClassName, BootCritical, Driver, @{ Name = 'FileRepository'; Expression = { ($_.OriginalFileName.split('\')[-2]) } } | Format-Table -AutoSize
    }
    #=================================================
}