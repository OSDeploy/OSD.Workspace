function Step-BuildMediaExportWindowsDriverPE {
    [CmdletBinding()]
    param (
        $WindowsImage = $global:WindowsImage,
        [System.String]
        $BuildMediaCorePath = $global:BuildMediaCorePath
    )
    #=================================================
    $Error.Clear()
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] WindowsImage: $WindowsImage"
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] BuildMediaCorePath: $BuildMediaCorePath"
    #=================================================
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Export Get-WindowsDriver $BuildMediaCorePath\winpe-windowsdriver.json"
    $WindowsDriver = $WindowsImage | Get-WindowsDriver
    if ($WindowsDriver) {
        $WindowsDriver | Select-Object * | Export-Clixml -Path "$BuildMediaCorePath\winpe-windowsdriver.xml" -Force
        $WindowsDriver | ConvertTo-Json -Depth 5 | Out-File "$BuildMediaCorePath\winpe-windowsdriver.json" -Encoding utf8 -Force
        $WindowsDriver | Sort-Object ProviderName, CatalogFile, Version | Select-Object ProviderName, CatalogFile, Version, Date, ClassName, BootCritical, Driver, @{ Name = 'FileRepository'; Expression = { ($_.OriginalFileName.split('\')[-2]) } } | Format-Table -AutoSize
    }
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}