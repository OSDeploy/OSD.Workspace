function Step-BuildMediaWinPEDriver {
    [CmdletBinding()]
    param (
        [System.String]
        $MountPath = $global:BuildMedia.MountPath,
        $WinPEDriver = $global:BuildMedia.WinPEDriver,
        [System.String]
        $LogsPath = $global:BuildMediaLogsPath,
        $WindowsImage = $global:WindowsImage
    )
    #=================================================
    $Error.Clear()
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Start"
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] MountPath: $MountPath"
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] WinPEDriver: $WinPEDriver"
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] LogsPath: $LogsPath"
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] WindowsImage: $WindowsImage"
    #=================================================
    if ($WinPEDriver) {
        Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] WinPEDriver: Add-WindowsDriver"
        foreach ($DriverPath in $WinPEDriver) {
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
                Write-Warning "WinPEDriver $DriverPath (not found)"
            }
        }
    }
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}