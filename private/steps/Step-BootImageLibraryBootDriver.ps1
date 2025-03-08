function Step-BootImageLibraryBootDriver {
    [CmdletBinding()]
    param (
        [System.String]
        $MountPath = $global:BuildMedia.MountPath,
        $BootDriver = $global:BuildMedia.BootDriver,
        $BuildMediaLogs = $global:BuildMediaLogs,
        $WindowsImage = $global:WindowsImage
    )
    if ($BootDriver) {
        Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] BootDriver: Add-WindowsDriver"
        foreach ($DriverPath in $BootDriver) {
            if (Test-Path $DriverPath) {
                # $ArchName = ( $DriverPath.FullName -split '\\' | Select-Object -last 3 ) -join '\'
                # Write-Host -ForegroundColor DarkGray $ArchName
                Write-Host -ForegroundColor DarkGray "$DriverPath"
                $CurrentLog = "$BuildMediaLogs\$((Get-Date).ToString('yyMMdd-HHmmss'))-Add-WindowsDriver.log"
        
                try {
                    # Dism
                    #dism.exe /image:$MountPath /Add-Driver /Driver:"$($DriverPath.FullName)" /Recurse /ForceUnsigned
                    #Start-Process dism.exe -ArgumentList "/Image:""$MountPath""", '/Add-Package', "/PackagePath:""$PackageFile""", '/IgnoreCheck' -NoNewWindow -Wait

                    # PowerShell
                    $null = $WindowsImage | Add-WindowsDriver -Driver $DriverPath -ForceUnsigned -Recurse -LogPath "$CurrentLog" -ErrorAction Stop
                }
                catch {
                    Write-Error -Message 'Driver failed to install. Root cause may be found in the following Dism Log'
                    Write-Error -Message "$CurrentLog"
                }
            }
            else {
                Write-Warning "BootDriver $DriverPath (not found)"
            }
        }
    }
}