function New-OSDWorkspaceUSB {
    <#
    .SYNOPSIS
        Creates a new OSDWorkspace USB bootable drive with WinPE boot media.

    .DESCRIPTION
        The New-OSDWorkspaceUSB function creates a new bootable USB drive from a selected 
        OSDWorkspace WinPE Build. This function prepares the USB drive for booting into WinPE 
        by partitioning, formatting, and copying necessary boot files.
        
        This function performs the following operations:
        1. Validates administrator privileges
        2. Prompts for selection of a WinPE Build using Select-OSDWSWinPEBuild
        3. Prompts for selection of a Media type (WinPE-Media or WinPE-MediaEX)
        4. Disables Autorun for the USB drive
        5. Prompts for selection of a USB drive that meets size requirements
        6. Clears all data from the selected USB drive (with confirmation)
        7. Initializes the disk with MBR partition style
        8. Creates and formats a 4GB FAT32 boot partition (active)
        9. Creates and formats an NTFS data partition using remaining space
        10. Copies the selected WinPE media files to the bootable partition
        
        The function creates a dual-partition structure:
        - A FAT32 bootable partition (4GB) containing WinPE boot files
        - An NTFS data partition using the remaining space

    .PARAMETER BootLabel
        Specifies the volume label for the boot partition.
        Default value is 'USB-WinPE'.
        Maximum length is 11 characters due to FAT32 filesystem limitations.

    .PARAMETER DataLabel
        Specifies the volume label for the data partition.
        Default value is 'USB-DATA'.
        Maximum length is 32 characters due to NTFS filesystem limitations.

    .EXAMPLE
        New-OSDWorkspaceUSB
        
        Creates a new OSDWorkspace USB with default labels for boot and data partitions.
        Uses 'USB-WinPE' for the boot partition and 'USB-DATA' for the data partition.

    .EXAMPLE
        New-OSDWorkspaceUSB -BootLabel 'BOOT' -DataLabel 'OSDDATA'
        
        Creates a new OSDWorkspace USB with custom labels for boot and data partitions.
        Uses 'BOOT' for the boot partition and 'OSDDATA' for the data partition.

    .EXAMPLE
        New-OSDWorkspaceUSB -Verbose
        
        Creates a new OSDWorkspace USB with detailed verbose output showing each step of the process.

    .OUTPUTS
        Microsoft.Management.Infrastructure.CimInstance#root/Microsoft/Windows/Storage/MSFT_Disk
        Returns the configured USB disk object.

    .NOTES
        Author: David Segura
        Version: 1.0
        Date: April 2025
        
        Prerequisites:
            - PowerShell 5.0 or higher
            - Windows 10 or higher (Windows 11 recommended)
            - Windows 10 build 1703 or higher
            - Run as Administrator
            - At least one WinPE build available in the OSDWorkspace
            - USB drive with minimum capacity of 7GB
        
        WARNING: This function will erase ALL data on the selected USB drive.
        A confirmation prompt will be displayed before erasing the drive.
        
        For drives larger than 2TB, the current GPT implementation is commented out
        as it is not working as expected for bootable drives.
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
    # Select a USB Disk
    Write-Verbose '$SelectDisk = Invoke-SelectUSBDisk -MinimumSizeGB $MinimumSizeGB -MaximumSizeGB $MaximumSizeGB'
    $SelectDisk = Invoke-SelectUSBDisk -MinimumSizeGB $MinimumSizeGB -MaximumSizeGB $MaximumSizeGB

    if (-NOT ($SelectDisk)) {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] No USB Drives that met the required criteria were detected"
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] MinimumSizeGB: $MinimumSizeGB"
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] MaximumSizeGB: $MaximumSizeGB"
        Break
    }
    #=================================================
    # Get-OSDDisk -BusType USB
    # At this point I have the Disk object in $GetUSBDisk
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] `$GetUSBDisk = Get-OSDDisk -BusType USB -Number `$SelectDisk.Number"
    $GetUSBDisk = Get-OSDDisk -BusType USB -Number $SelectDisk.Number

    $GetUSBDisk | Select-Object -Property * -ExcludeProperty Cim*,PS*,Pass*
    #=================================================
    # Clear-Disk Prompt for Confirmation
    if ($GetUSBDisk.NumberOfPartitions -eq 0) {
        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Disk does not have any partitions.  This is a good thing!"
    }
    else {
        Write-Verbose '$GetUSBDisk | Clear-Disk -RemoveData -RemoveOEM -Confirm:$true'
        $GetUSBDisk | Clear-Disk -RemoveData -RemoveOEM -Confirm:$true -ErrorAction Stop
    }
    #=================================================
    # Get-OSDDisk -BusType USB
    Write-Verbose '$GetUSBDisk = Get-OSDDisk -BusType USB -Number $SelectDisk.Number | Where-Object {$_.NumberOfPartitions -eq 0}'
    $GetUSBDisk = Get-OSDDisk -BusType USB -Number $SelectDisk.Number | Where-Object {$_.NumberOfPartitions -eq 0}

    if (-NOT ($GetUSBDisk)) {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Something went very very wrong in this process"
        Break
    }
    #=================================================
    #	-lt 2TB
    #=================================================
    if ($GetUSBDisk.PartitionStyle -eq 'RAW') {
        Write-Verbose '$GetUSBDisk | Initialize-Disk -PartitionStyle MBR'
        $GetUSBDisk | Initialize-Disk -PartitionStyle MBR -ErrorAction Stop
    }
    if ($GetUSBDisk.PartitionStyle -eq 'GPT') {
        Write-Verbose '$GetUSBDisk | Set-Disk -PartitionStyle MBR'
        Set-Disk -Number $GetUSBDisk.Number -PartitionStyle MBR -ErrorAction Stop
    }
    if ($GetUSBDisk.SizeGB -le 2000) {
        $BootPartition = $GetUSBDisk | New-Partition -Size 4GB -IsActive -AssignDriveLetter | Format-Volume -FileSystem FAT32 -NewFileSystemLabel $BootLabel -ErrorAction Stop
        # $PEBOOTA = $GetUSBDisk | New-Partition -Size 4GB -IsActive -AssignDriveLetter | Format-Volume -FileSystem FAT32 -NewFileSystemLabel 'WinPE-AMD64' -ErrorAction Stop
        # $PEBOOTB = $GetUSBDisk | New-Partition -Size 4GB -IsActive -AssignDriveLetter | Format-Volume -FileSystem FAT32 -NewFileSystemLabel 'WinPE-ARM64' -ErrorAction Stop
        $DataPartition = $GetUSBDisk | New-Partition -UseMaximumSize -AssignDriveLetter | Format-Volume -FileSystem NTFS -NewFileSystemLabel $DataLabel -ErrorAction Stop
    }
    #=================================================
    #	-ge 2TB
    #   This is not working as expected and will probably not be bootable
    #   So leaving it in here for historic purposes
    #=================================================
    <#  if ($GetUSBDisk.SizeGB -gt 1800) {
        $GetUSBDisk | Initialize-Disk -PartitionStyle GPT
        $DataPartition = $GetUSBDisk | New-Partition -Size ($GetUSBDisk.Size - 2GB) -AssignDriveLetter | `
        Format-Volume -FileSystem NTFS -NewFileSystemLabel $DataLabel

        $BootPartition = $GetUSBDisk | New-Partition -GptType "{c12a7328-f81f-11d2-ba4b-00a0c93ec93b}" -UseMaximumSize -AssignDriveLetter | `
        Format-Volume -FileSystem FAT32 -NewFileSystemLabel $BootLabel
    } #>
    #=================================================
    # WinpeDestinationPath
    $WinpeDestinationPath = "$($BootPartition.DriveLetter):\"
    if (-NOT ($WinpeDestinationPath)) {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to find Destination Path at $WinpeDestinationPath"
        Break
    }
    #=================================================
    # Update WinPE Volume
    if ((Test-Path -Path "$($BootMediaObject.FullName)") -and (Test-Path -Path "$WinpeDestinationPath")) {
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying $($BootMediaObject.FullName) to BootPartition partition at $BootLabel"
        robocopy "$($BootMediaObject.FullName)" "$WinpeDestinationPath" *.* /e /ndl /njh /njs /np /r:0 /w:0 /b /zb
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
