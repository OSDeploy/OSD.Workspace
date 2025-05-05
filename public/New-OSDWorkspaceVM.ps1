function New-OSDWorkspaceVM {
    <#
    .SYNOPSIS
        Creates a customized Hyper-V virtual machine from selected OSDWorkspace WinPE build media.

    .DESCRIPTION
        The New-OSDWorkspaceVM function creates a Hyper-V virtual machine that boots from the selected
        OSDWorkspace WinPE build media. This VM can be used for testing WinPE deployments, scripts, 
        and other OSD tools in a virtualized environment.
        
        This function performs the following operations:
        1. Validates that Hyper-V is available on the system
        2. Prompts for selection of a WinPE build using Select-OSDWSWinPEBuild
        3. Prompts for selection of a Media type (WinPE-Media or WinPE-MediaEX)
        4. Creates a new Hyper-V VM with specified parameters
        5. Configures secure boot, TPM, and other settings based on the VM generation
        6. Mounts the selected ISO to the VM's DVD drive
        7. Optionally creates an initial checkpoint
        8. Optionally starts the VM
        
        The VM is highly customizable with options for memory, CPU, networking, display resolution,
        and storage configuration.

    .PARAMETER CheckpointVM
        Specifies whether to create a checkpoint of the VM after creation.
        Default value is $true.

    .PARAMETER Generation
        Specifies the Hyper-V VM generation to create.
        Valid values are 1 or 2.
        Default value is 2.
        Generation 1 VMs support legacy BIOS, while Generation 2 VMs support UEFI and secure boot.

    .PARAMETER MemoryStartupGB
        Specifies the amount of startup memory for the VM in gigabytes.
        Default value is 4.

    .PARAMETER NamePrefix
        Specifies a prefix for the VM name. The actual VM name will be in the format "NamePrefix-yyyy-MM-dd-HHmmss".
        Default value is 'OSDWS'.

    .PARAMETER ProcessorCount
        Specifies the number of virtual processors to allocate to the VM.
        Default value is 2.
        
    .PARAMETER DisplayResolution
        Specifies the display resolution of the VM.
        Valid values include '1024x768', '1280x720', '1280x768', '1280x800', '1280x960', '1280x1024', 
        '1360x768', '1366x768', '1600x900', '1600x1200', '1680x1050', '1920x1080', and '1920x1200'.
        Default value is '1280x720'.

    .PARAMETER StartVM
        Specifies whether to start the VM after creation.
        Default value is $true.

    .PARAMETER SwitchName
        Specifies the name of the virtual switch to connect the VM to.
        Default value is 'Default Switch'.

    .PARAMETER VHDSizeGB
        Specifies the size of the virtual hard disk in gigabytes.
        Default value is 20.

    .EXAMPLE
        New-OSDWorkspaceVM
        
        Creates a Hyper-V VM with default settings (Generation 2, 4GB RAM, 2 CPUs, 20GB VHD),
        prompting for WinPE build selection.

    .EXAMPLE
        New-OSDWorkspaceVM -NamePrefix 'TestDeploy' -MemoryStartupGB 8 -ProcessorCount 4 -VHDSizeGB 50
        
        Creates a customized Hyper-V VM with the name prefix 'TestDeploy', 8GB of RAM,
        4 processors, and a 50GB virtual hard disk.

    .EXAMPLE
        New-OSDWorkspaceVM -CheckpointVM $false -Generation 2 -MemoryStartupGB 8 -NamePrefix 'MyVM' -ProcessorCount 4 -DisplayResolution '1920x1080' -StartVM $false -SwitchName 'MySwitch' -VHDSizeGB 50
        
        Creates a Generation 2 Hyper-V VM with 8GB of memory, 4 processors, 1920x1080 display resolution,
        and a 50GB VHD. The VM will not be started automatically and will not have an initial checkpoint created.
        
    .OUTPUTS
        Microsoft.HyperV.PowerShell.VirtualMachine
        Returns the created Hyper-V virtual machine object.

    .NOTES
        Author: David Segura
        Version: 1.0
        Date: April 29, 2025
        
        Prerequisites:
            - PowerShell 5.0 or higher
            - Windows 10/11 Pro, Enterprise, or Server with Hyper-V role installed
            - Run as Administrator
            - At least one WinPE build available in the OSDWorkspace
            
        This function requires the Hyper-V PowerShell module to be installed and available.
    #>

    
    [CmdletBinding()]
    param (
        # Specifies whether to create a checkpoint of the VM after creation. Default is $true.
        [System.Boolean]
        $CheckpointVM = $true,

        # Specifies the generation of the VM. Default is 2.
        [ValidateSet('1','2')]
        [System.UInt16]
        $Generation = 2,

        # Specifies the amount of memory in whole number GB to allocate to the VM. Default is 10. Maximum is 64.
        [ValidateRange(2, 64)]
        [System.UInt16]
        $MemoryStartupGB = 10,

        # Specifies the prefix to use for the VM name. Default is 'OSDWorkspace'. Full VM name will be in the format 'yyMMdd-HHmm 'NamePrefix' MediaName'.
        [System.String]
        $NamePrefix = 'OSDWorkspace',

        # Specifies the number of processors to allocate to the VM. Default is 2. Maximum is 64.
        [ValidateRange(2, 64)]
        [System.UInt16]
        $ProcessorCount = 2,

        # Specifies the display resolution of the VM. Default is '1440x900'.
        [ValidateSet('640x480','800x600','1024x768','1152x864','1280x720',
        '1280x768','1280x800','1280x960','1280x1024','1360x768','1366x768',
        '1400x1050','1440x900','1600x900','1680x1050','1920x1080','1920x1200',
        '2560x1440','2560x1600','3840x2160','3840x2400','4096x2160')]
        [System.String]
        $DisplayResolution = '1600x900',

        # Specifies whether to start the VM after creation. Default is $true.
        [System.Boolean]
        $StartVM = $true,

        # Specifies the name of the virtual switch to connect the VM to. If not specified, an Out-GridView will be displayed to select a switch.
        [System.String]
        $SwitchName,

        # Specifies the size of the VHD in whole number GB. Default is 64. Maximum is 128.
        [ValidateRange(8, 128)]
        [System.UInt16]
        $VHDSizeGB = 64
    )
    #=================================================
    $Error.Clear()
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Start"
    Initialize-OSDWorkspace
    #=================================================
    # Requires Run as Administrator
    $IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $IsAdmin ) {
        Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] This function must be Run as Administrator"
        return
    }
    #=================================================
    # Is Hyper-V enabled?
    if (Test-IsHyperVEnabled) {
        Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Hyper-V is enabled"
    }
    else {
        Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Hyper-V is not enabled, or may not be compatible with this version of Windows. Try running the following elevated Admin command:"
        Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Enable-WindowsOptionalFeature -Online -FeatureName 'Microsoft-Hyper-V-All' -NoRestart"
        return
    }
    #=================================================
    # Can only make a VM matching the architecture of the running OS
    $Architecture = $Env:PROCESSOR_ARCHITECTURE
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Architecture = $Architecture"
    #=================================================
    # Do we have a Boot Media?
    $SelectWinPEBuild = $null
    $SelectWinPEBuild = Select-OSDWSWinPEBuild -Architecture $Architecture
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] SelectWinPEBuild: $SelectWinPEBuild"

    if ($null -eq $SelectWinPEBuild) {
        Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] No OSDWorkspace WinPE Build was found or selected"
        return
    }
    #=================================================
    # Get Hyper-V Defaults
    #$VMManagementService = Get-WmiObject -Namespace root\virtualization\v2 Msvm_VirtualSystemManagementService
    $VMManagementServiceSettingData = Get-WmiObject -Namespace root\virtualization\v2 Msvm_VirtualSystemManagementServiceSettingData
    #=================================================
    # Set the Boot ISO
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Select a OSDWorkspace WinPE Build ISO to use with this Virtual Machine (Cancel to exit)"
    $SelectDvdDrive = Get-ChildItem "$($SelectWinPEBuild.Path)\iso" *.iso | Sort-Object Name, FullName | Select-Object Name, FullName | Out-GridView -Title 'Select a OSDWorkspace WinPE Build ISO to use with this Virtual Machine' -OutputMode Single
    if ($null -eq $SelectDvdDrive) {
        Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] No OSDWorkspace WinPE Build ISO was found"
        return
    }
    $DvdDrivePath = $SelectDvdDrive.FullName
    #=================================================
    # Select a Default Switch
    if (-not ($SwitchName)) {
        $GetVMSwitch = Get-VMSwitch -ErrorAction SilentlyContinue
        if ($GetVMSwitch.Count -ge 1) {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Virtual Switch Name was not specified with the SwitchName parameter"
            $SwitchName = Get-VMSwitch | Select-Object Name, SwitchType, Id | Out-GridView -Title 'Select a Virtual Switch to use with this Virtual Machine (Cancel = Not connected)' -OutputMode Single | Select-Object -ExpandProperty Name
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] SwitchName: $SwitchName"
        }
        else {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] No Virtual Switches found with Get-VMSwitch, you will have to create a Virtual Switch. Setting to Not connected"
            $SwitchName = $null
        }
    }
    #=================================================
    # Automatically Set VM Name
    if ($SelectWinPEBuild.Name) {
        $VmName = "$((Get-Date).ToString('yyMMdd-HHmm')) $NamePrefix $($SelectWinPEBuild.Name)"
    }
    else {
        $VmName = "$((Get-Date).ToString('yyMMdd-HHmm')) $NamePrefix"
    }
    #=================================================
    # Set the Display Resolution

    #=================================================
    # Set Variables
    $VHDPath = [System.String](Join-Path $VMManagementServiceSettingData.DefaultVirtualHardDiskPath "$VmName.vhdx")            
    $VHDSizeBytes = ($VHDSizeGB * 1GB)
    $VHDSizeGB = [System.Int64]$VHDSizeGB
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] MemoryStartupGB: $MemoryStartupGB"
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] The -MemoryStartupGB parameter is used to specify the amount of memory in GB to allocate to the VM"
    $MemoryStartupBytes = ($MemoryStartupGB * 1GB)
    #=================================================
    # Create VM VHD
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] New-VM: Creating Virtual Machine in (5 second delay)"
    Start-Sleep -Seconds 5
    if ($SwitchName) {
        $vm = New-VM -Name $VmName -Generation $Generation -MemoryStartupBytes $MemoryStartupBytes -NewVHDPath $VHDPath -NewVHDSizeBytes $VHDSizeBytes -SwitchName $SwitchName -ErrorAction Stop
    }
    else {
        $vm = New-VM -Name $VmName -Generation $Generation -MemoryStartupBytes $MemoryStartupBytes -NewVHDPath $VHDPath -NewVHDSizeBytes $VHDSizeBytes -ErrorAction Stop
    }
    #=================================================
    # Add DVD Drive
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Add-VMDvdDrive -Path $DvdDrivePath"
    $DvdDrive = $vm | Add-VMDvdDrive -Path $DvdDrivePath -Passthru
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Get-VMHardDiskDrive"
    $HardDiskDrive = $vm | Get-VMHardDiskDrive
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Get-VMNetworkAdapter"
    $NetworkAdapter = $vm | Get-VMNetworkAdapter
    #=================================================
    # Generation
    if ($Generation -eq 2) {
        # First Boot Device
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Set-VMFirmware -FirstBootDevice"
        $vm | Set-VMFirmware -FirstBootDevice $DvdDrive

        # Firmware
        #$vm | Set-VMFirmware -BootOrder $DvdDrive, $vmHardDiskDrive, $vmNetworkAdapter -Verbose

        # Security
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Set-VMFirmware -EnableSecureBoot On"
        $vm | Set-VMFirmware -EnableSecureBoot On
        if ((Get-TPM).TpmPresent -eq $true -and (Get-TPM).TpmReady -eq $true) {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Set-VMSecurity -VirtualizationBasedSecurityOptOut:`$false"
            $vm | Set-VMSecurity -VirtualizationBasedSecurityOptOut:$false
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Set-VMKeyProtector -NewLocalKeyProtector"
            $vm | Set-VMKeyProtector -NewLocalKeyProtector
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Enable-VMTPM"
            $vm | Enable-VMTPM
        }
    }
    #=================================================
    # Memory
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Set-VMMemory -DynamicMemoryEnabled False"
    $vm | Set-VMMemory -DynamicMemoryEnabled $false
    #=================================================
    # Processor
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] ProcessorCount: $ProcessorCount"
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] The -ProcessorCount parameter is used to set the number of processors to allocate to the VM. Default is 2"
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Set-VMProcessor -Count $($ProcessorCount)"
    $vm | Set-VMProcessor -Count $ProcessorCount
    #=================================================
    # Display Resolution
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] DisplayResolution: $DisplayResolution"
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] The -DisplayResolution parameter is used to set the resolution of the Virtual Machine. Default is 1440x900"
    $HorizontalResolution = $DisplayResolution.Split('x')[0]
    $VerticalResolution = $DisplayResolution.Split('x')[1]
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Set-VMVideo -HorizontalResolution $($HorizontalResolution) -VerticalResolution $($VerticalResolution) -ResolutionType Single"
    $vm | Set-VMVideo -HorizontalResolution $HorizontalResolution -VerticalResolution $VerticalResolution -ResolutionType Single
    #=================================================
    # Integration Services
    # Thanks Andreas Landry
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Enable-VMIntegrationService"
    $IntegrationService = Get-VMIntegrationService -VMName $vm.Name | Where-Object { $_ -match 'Microsoft:[0-9A-Fa-f]{8}[-][0-9A-Fa-f]{4}[-][0-9A-Fa-f]{4}[-][0-9A-Fa-f]{4}[-][0-9A-Fa-f]{12}\\6C09BB55-D683-4DA0-8931-C9BF705F6480' }
    $vm | Get-VMIntegrationService -Name $IntegrationService.Name | Enable-VMIntegrationService
    #=================================================
    # Checkpoints Start Stop
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Set-VM -AutomaticCheckpointsEnabled `$false -AutomaticStartAction Nothing -AutomaticStartDelay 3 -AutomaticStopAction Shutdown"
    $vm | Set-VM -AutomaticCheckpointsEnabled $false -AutomaticStartAction Nothing -AutomaticStartDelay 3 -AutomaticStopAction Shutdown
    #=================================================
    # Create a Snapshot
    if ($CheckpointVM -eq $true) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Checkpoint-VM -SnapshotName 'New-VM'"
        $vm | Checkpoint-VM -SnapshotName 'New-VM'
    }
    #=================================================
    # Export Final Configuration
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Exporting current configuration to $($SelectWinPEBuild.Path)\vm.json"
    $vm | ConvertTo-Json -Depth 5 | Out-File -FilePath "$($SelectWinPEBuild.Path)\vm.json" -Force
    #=================================================
    # Start VM
    if ($StartVM -eq $true) {
        Write-Host -ForegroundColor DarkCyan "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] vmconnect.exe `"$($env:ComputerName) $VmName`""
        vmconnect.exe $env:ComputerName $VmName
        Start-Sleep -Seconds 10
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Start-VM"
        $vm | Start-VM
    }
    #=================================================
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}
Register-ArgumentCompleter -CommandName New-OSDWorkspaceVM -ParameterName 'SwitchName' -ScriptBlock {Get-VMSwitch | Select-Object -ExpandProperty Name | ForEach-Object {if ($_.Contains(' ')) {"'$_'"} else {$_}}}