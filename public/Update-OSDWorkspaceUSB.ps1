function Update-OSDWorkspaceUSB {
    <#
    .SYNOPSIS
        Updates an existing OSDWorkspace USB drive with new WinPE boot media files.

    .DESCRIPTION
        The Update-OSDWorkspaceUSB function refreshes an existing OSDWorkspace bootable USB drive 
        with updated WinPE boot media files from a selected OSDWorkspace WinPE Build.
        
        This function performs the following operations:
        1. Validates administrator privileges
        2. Prompts for selection of a WinPE Build using Select-OSDWSWinPEBuild
        3. Prompts for selection of a Media type (WinPE-Media or WinPE-MediaEX)
        4. Disables Autorun for the USB drive
        5. Locates existing USB volumes labeled 'USB-WinPE'
        6. Copies the selected WinPE media files to the bootable partition
        7. Creates a BootMedia.json file with build information
        
        No partitioning or formatting is performed, as this function is designed to update 
        an existing USB drive that was previously created with New-OSDWorkspaceUSB.

    .PARAMETER BootLabel
        Specifies the volume label for the boot partition.
        Default value is 'USB-WinPE'.
        Maximum length is 11 characters due to FAT32 filesystem limitations.

    .PARAMETER DataLabel
        Specifies the volume label for the data partition.
        Default value is 'USB-DATA'.
        Maximum length is 32 characters due to NTFS filesystem limitations.

    .EXAMPLE
        Update-OSDWorkspaceUSB
        
        Updates an existing OSDWorkspace USB drive with the selected OSDWorkspace WinPE Build.
        Uses the default labels 'USB-WinPE' for boot partition and 'USB-DATA' for data partition.

    .EXAMPLE
        Update-OSDWorkspaceUSB -BootLabel 'BOOT' -DataLabel 'DATA'
        
        Updates an existing OSDWorkspace USB drive with the selected OSDWorkspace WinPE Build.
        Uses the custom labels 'BOOT' for boot partition and 'DATA' for data partition.

    .EXAMPLE
        Update-OSDWorkspaceUSB -Verbose
        
        Updates an existing OSDWorkspace USB drive with detailed verbose output showing each step of the process.

    .OUTPUTS
        Microsoft.Management.Infrastructure.CimInstance#root/Microsoft/Windows/Storage/MSFT_Disk
        Returns the updated USB disk object.

    .NOTES
        Author: David Segura
        Version: 1.0
        Date: April 2025
        
        Prerequisites:
            - PowerShell 5.0 or higher
            - Windows 10 or higher
            - Run as Administrator
            - An existing OSDWorkspace USB drive created with New-OSDWorkspaceUSB
            - At least one WinPE build available in the OSDWorkspace
        
        The function searches for USB volumes labeled 'USB-WinPE' to update. If no matching 
        volumes are found, the function will display a warning and exit.
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
    $SelectWinPEMedia = Select-OSDWSWinPEBuild

    if ($null -eq $SelectWinPEMedia) {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] No OSDWorkspace WinPE Build was found or selected"
        return
    }
    #=================================================
    # Select a BootMedia Media folder
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Select an OSDWorkspace WinPE Build to use with this USB (Cancel to exit)"
    $BootMediaObject = Get-ChildItem $($SelectWinPEMedia.Path) -Directory | Where-Object { ($_.Name -eq 'WinPE-Media') -or ($_.Name -eq 'WinPE-MediaEX') } | Sort-Object Name, FullName | Select-Object Name, FullName | Out-GridView -Title 'Select an OSDWorkspace WinPE Build to use with this USB (Cancel to exit)' -OutputMode Single
    if ($null -eq $BootMediaObject) {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] No WinPE-Media or WinPE-MediaEX subfolders were found"
        return
    }
    $BootMediaArch = $SelectWinPEMedia.Architecture.ToUpper()
    #$BootLabel = "WinPE-$($BootMediaArch)"
    #=================================================
    # Disable Autorun
    Set-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' -Name NoDriveTypeAutorun -Type DWord -Value 0xFF -ErrorAction SilentlyContinue
    #=================================================
    # Update WinPE Volume
    if (Test-Path -Path $BootMediaObject.FullName) {
        $WinpeVolumes = Get-USBVolume | Where-Object { $_.FileSystemLabel -eq 'USB-WinPE' }
        if ($WinpeVolumes) {
            Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying $($BootMediaObject.FullName) to USB-WinPE partitions"
            foreach ($volume in $WinpeVolumes) {
                if (Test-Path -Path "$($volume.DriveLetter):\") {
                    robocopy "$($BootMediaObject.FullName)" "$($volume.DriveLetter):\" *.* /e /ndl /r:0 /w:0 /xd '$RECYCLE.BIN' 'System Volume Information' /xj
                }
                $SelectWinPEMedia | ConvertTo-Json -Depth 5 | Out-File -FilePath "$($volume.DriveLetter):\BootMedia.json" -Force
            }
        }
        else {
            Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Unable to find a USB Partition labeled USB-WinPE to update"
        }
    }
    #=================================================
    # Remove Read-Only Attribute
    <#
    Get-ChildItem -Path $WinpeDestinationPath -File -Recurse -Force | ForEach-Object {
        Set-ItemProperty -Path $_.FullName -Name IsReadOnly -Value $false -Force -ErrorAction Ignore
    }
    #>
    #=================================================
    return (Get-OSDDisk -BusType USB -Number $SelectDisk.Number)
    #=================================================
}
