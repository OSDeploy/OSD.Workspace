function Step-BootImageLibraryBuildWinPEDriver {
    [CmdletBinding()]
    param (
        [System.String]
        $MountPath = $global:BuildMedia.MountPath,
        $BuildWinPEDriver = $global:BuildMedia.BuildWinPEDriver,
        $BuildMediaLogs = $global:BuildMediaLogs,
        $WindowsImage = $global:WindowsImage
    )
    if ($BuildWinPEDriver) {
        Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] BuildWinPEDriver: Add-WindowsDriver"
        foreach ($DriverPath in $BuildWinPEDriver) {
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
                Write-Warning "BuildWinPEDriver $DriverPath (not found)"
            }
        }
    }
}