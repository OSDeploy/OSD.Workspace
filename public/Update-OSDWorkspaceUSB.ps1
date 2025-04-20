function Update-OSDWorkspaceUSB {
    <#
    .SYNOPSIS
        Updates an Existing OSDWorkspace USB drive with new BootMedia files.

    .DESCRIPTION
        This function updates an existing OSDWorkspace USB drive with the selected OSDWorkspace WinPE Build.

    .EXAMPLE
        Update-OSDWorkspaceUSB
        Updates an existing OSDWorkspace USB drive with the selected OSDWorkspace WinPE Build and uses default labels for boot and data partitions.

    .EXAMPLE
        Update-OSDWorkspaceUSB -BootLabel 'MYBOOT' -DataLabel 'MYDATA'
        Updates an existing OSDWorkspace USB drive with the selected OSDWorkspace WinPE Build and uses the boot label 'MYBOOT' and data label 'MYDATA'.

    .NOTES
        David Segura
    #>
    [CmdletBinding()]
    param (
        # Label for the boot partition. Default is 'USB-WinPE'.
        [ValidateLength(0,11)]
        [string]
        $BootLabel = 'USB-WinPE',

        # Label for the data partition. Default is 'USB-DATA'.
        [ValidateLength(0,32)]
        [string]
        $DataLabel = 'USB-DATA'
    )
    #=================================================
    $Error.Clear()
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Start"
    Initialize-OSDWorkspace
    #=================================================
    # Requires Run as Administrator
    $IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $IsAdmin ) {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] This function must be Run as Administrator"
        return
    }
    #=================================================
    # Set Variables
    $ErrorActionPreference = 'Stop'
    $MinimumSizeGB = 7
    $MaximumSizeGB = 2000
    #=================================================
    # Block
    Block-StandardUser
    Block-WindowsVersionNe10
    Block-PowerShellVersionLt5
    Block-WindowsReleaseIdLt1703
    #=================================================
    # Do we have a Boot Media?
    $SelectBootMedia = Select-OSDWSWinPEBuild

    if ($null -eq $SelectBootMedia) {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] No OSDWorkspace WinPE Build was found or selected"
        return
    }
    #=================================================
    # Select a BootMedia Media folder
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Select an OSDWorkspace WinPE Build to use with this USB (Cancel to exit)"
    $BootMediaObject = Get-ChildItem $($SelectBootMedia.Path) -Directory | Where-Object { ($_.Name -eq 'WinPE-Media') -or ($_.Name -eq 'WinPE-MediaEX') } | Sort-Object Name, FullName | Select-Object Name, FullName | Out-GridView -Title 'Select an OSDWorkspace WinPE Build to use with this USB (Cancel to exit)' -OutputMode Single
    if ($null -eq $BootMediaObject) {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] No WinPE-Media or WinPE-MediaEX subfolders were found"
        return
    }
    $BootMediaArch = $SelectBootMedia.Architecture.ToUpper()
    #$BootLabel = "WinPE-$($BootMediaArch)"
    #=================================================
    # Disable Autorun
    Set-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' -Name NoDriveTypeAutorun -Type DWord -Value 0xFF -ErrorAction SilentlyContinue
    #=================================================
    #	Update WinPE Volume
    #=================================================
    if (Test-Path -Path $BootMediaObject.FullName) {
        $WinpeVolumes = Get-USBVolume | Where-Object { $_.FileSystemLabel -eq 'USB-WinPE' }
        if ($WinpeVolumes) {
            Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying $($BootMediaObject.FullName) to USB-WinPE partitions"
            foreach ($volume in $WinpeVolumes) {
                if (Test-Path -Path "$($volume.DriveLetter):\") {
                    robocopy "$($BootMediaObject.FullName)" "$($volume.DriveLetter):\" *.* /e /ndl /r:0 /w:0 /xd '$RECYCLE.BIN' 'System Volume Information' /xj
                }
                $SelectBootMedia | ConvertTo-Json -Depth 5 | Out-File -FilePath "$($volume.DriveLetter):\osdworkspace.json" -Force
            }
        }
        else {
            Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Unable to find a USB Partition labeled USB-WinPE to update"
        }
    }
    #=================================================
    #	Remove Read-Only Attribute
    #=================================================
    <#
    Get-ChildItem -Path $WinpeDestinationPath -File -Recurse -Force | ForEach-Object {
        Set-ItemProperty -Path $_.FullName -Name IsReadOnly -Value $false -Force -ErrorAction Ignore
    }
    #>
    #=================================================
    #	Return
    #=================================================
    Return (Get-OSDDisk -BusType USB -Number $SelectDisk.Number)
    #=================================================
}
