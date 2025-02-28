function New-OSDWorkspaceUSB {
    [CmdletBinding()]
    param (
        [ValidateLength(0,11)]
        [string]$BootLabel = 'WINPE',

        [ValidateLength(0,32)]
        [string]$DataLabel = 'USB Data'
    )
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
    $Error.Clear()
    #=================================================
    # Check for Administrator
    $IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $IsAdmin ) {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] must be run with Administrator privileges"
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
    $SelectBootMedia = Select-OSDWorkspaceBootMedia

    if ($null -eq $SelectBootMedia) {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] No OSDWorkspace BootMedia was found or selected"
        return
    }
    #=================================================
    # Select a BootMedia Media folder
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Select an OSDWorkspace BootMedia to use with this USB (Cancel to exit)"
    $BootMediaObject = Get-ChildItem $($SelectBootMedia.Path) -Directory | Where-Object { ($_.Name -eq 'Media') -or ($_.Name -eq 'MediaEx') } | Sort-Object Name, FullName | Select-Object Name, FullName | Out-GridView -Title 'Select an OSDWorkspace BootMedia to use with this USB (Cancel to exit)' -OutputMode Single
    if ($null -eq $BootMediaObject) {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] No BootMedia path was found"
        return
    }
    $BootMediaArch = $SelectBootMedia.Architecture.ToUpper()
    $BootMediaLabel = "WinPE-$($BootMediaArch)"
    #=================================================
    # Disable Autorun
    Set-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' -Name NoDriveTypeAutorun -Type DWord -Value 0xFF -ErrorAction SilentlyContinue
    #=================================================
    # Select a USB Disk
    Write-Verbose '$SelectDisk = Invoke-SelectUSBDisk -MinimumSizeGB $MinimumSizeGB -MaximumSizeGB $MaximumSizeGB'
    $SelectDisk = Invoke-SelectUSBDisk -MinimumSizeGB $MinimumSizeGB -MaximumSizeGB $MaximumSizeGB

    if (-NOT ($SelectDisk)) {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] No USB Drives that met the required criteria were detected"
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] MinimumSizeGB: $MinimumSizeGB"
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] MaximumSizeGB: $MaximumSizeGB"
        Break
    }
    #=================================================
    # Get-OSDDisk -BusType USB
    # At this point I have the Disk object in $GetUSBDisk
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] `$GetUSBDisk = Get-OSDDisk -BusType USB -Number `$SelectDisk.Number"
    $GetUSBDisk = Get-OSDDisk -BusType USB -Number $SelectDisk.Number

    $GetUSBDisk | Select-Object -Property * -ExcludeProperty Cim*,PS*,Pass*
    #=================================================
    #	Clear-Disk Prompt for Confirmation
    #=================================================
    if ($GetUSBDisk.NumberOfPartitions -eq 0) {
        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Disk does not have any partitions.  This is a good thing!"
    }
    else {
        Write-Verbose '$GetUSBDisk | Clear-Disk -RemoveData -RemoveOEM -Confirm:$true'
        $GetUSBDisk | Clear-Disk -RemoveData -RemoveOEM -Confirm:$true -ErrorAction Stop
    }
    #=================================================
    #	Get-OSDDisk -BusType USB
    #	Run another Get-Disk to make sure that things are ok
    #=================================================
    Write-Verbose '$GetUSBDisk = Get-OSDDisk -BusType USB -Number $SelectDisk.Number | Where-Object {$_.NumberOfPartitions -eq 0}'
    $GetUSBDisk = Get-OSDDisk -BusType USB -Number $SelectDisk.Number | Where-Object {$_.NumberOfPartitions -eq 0}

    if (-NOT ($GetUSBDisk)) {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Something went very very wrong in this process"
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
        $BootPartition = $GetUSBDisk | New-Partition -Size 4GB -IsActive -AssignDriveLetter | Format-Volume -FileSystem FAT32 -NewFileSystemLabel $BootMediaLabel -ErrorAction Stop
        # $PEBOOTA = $GetUSBDisk | New-Partition -Size 4GB -IsActive -AssignDriveLetter | Format-Volume -FileSystem FAT32 -NewFileSystemLabel 'WinPE-AMD64' -ErrorAction Stop
        # $PEBOOTB = $GetUSBDisk | New-Partition -Size 4GB -IsActive -AssignDriveLetter | Format-Volume -FileSystem FAT32 -NewFileSystemLabel 'WinPE-ARM64' -ErrorAction Stop
        $DataPartition = $GetUSBDisk | New-Partition -UseMaximumSize -AssignDriveLetter | Format-Volume -FileSystem NTFS -NewFileSystemLabel 'USB-Data' -ErrorAction Stop
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
    #	WinpeDestinationPath
    #=================================================
    $WinpeDestinationPath = "$($BootPartition.DriveLetter):\"
    if (-NOT ($WinpeDestinationPath)) {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to find Destination Path at $WinpeDestinationPath"
        Break
    }
    #=================================================
    #	Update WinPE Volume
    #=================================================
    if ((Test-Path -Path "$($BootMediaObject.FullName)") -and (Test-Path -Path "$WinpeDestinationPath")) {
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying $($BootMediaObject.FullName) to BootPartition partition at $BootMediaLabel"
        robocopy "$($BootMediaObject.FullName)" "$WinpeDestinationPath" *.* /e /ndl /njh /njs /np /r:0 /w:0 /b /zb
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
    #	Complete
    #=================================================

    #=================================================
    #	Return
    #=================================================
    Return (Get-OSDDisk -BusType USB -Number $SelectDisk.Number)
    #=================================================
}
