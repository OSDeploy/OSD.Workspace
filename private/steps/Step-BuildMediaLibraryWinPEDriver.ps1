function Step-BuildMediaLibraryWinPEDriver {
    [CmdletBinding()]
    param (
        [System.String]
        $MountPath = $global:BuildMedia.MountPath,
        $LibraryWinPEDriver = $global:BuildMedia.LibraryWinPEDriver,
        [System.String]
        $LogsPath = $global:BuildMediaLogsPath,
        $WindowsImage = $global:WindowsImage
    )
    #=================================================
    $Error.Clear()
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] MountPath: $MountPath"
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] LibraryWinPEDriver: $LibraryWinPEDriver"
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] LogsPath: $LogsPath"
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] WindowsImage: $WindowsImage"
    #=================================================
    if ($LibraryWinPEDriver) {
        Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] LibraryWinPEDriver: Add-WindowsDriver"
        foreach ($DriverPath in $LibraryWinPEDriver) {
            if (Test-Path $DriverPath) {
                # $ArchName = ( $DriverPath.FullName -split '\\' | Select-Object -last 3 ) -join '\'
                # Write-Host -ForegroundColor DarkGray $ArchName
                Write-Host -ForegroundColor DarkGray "$DriverPath"
                $CurrentLog = "$LogsPath\$((Get-Date).ToString('yyMMdd-HHmmss'))-Add-WindowsDriver.log"
        
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
                Write-Warning "LibraryWinPEDriver $DriverPath (not found)"
            }
        }
    }
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}