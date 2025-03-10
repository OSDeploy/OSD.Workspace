function New-OSDWorkspaceVM {
    <#
    .SYNOPSIS
        Creates a Hyper-V VM for use with OSDWorkspace

    .DESCRIPTION
        Creates a Hyper-V VM for use with OSDWorkspace

    .PARAMETER CheckpointVM
        Specifies whether to create a checkpoint of the VM after creation. Default is $true.

    .PARAMETER Generation
        Specifies the generation of the VM. Default is 2.

    .PARAMETER MemoryStartupGB
        Specifies the amount of memory in whole number GB to allocate to the VM. Default is 10. Maximum is 64.

    .PARAMETER NamePrefix
        Specifies the prefix to use for the VM name. Default is 'OSDWorkspace'. Full VM name will be in the format 'yyMMdd-HHmm 'NamePrefix' MediaName'.

    .PARAMETER ProcessorCount
        Specifies the number of processors to allocate to the VM. Default is 2. Maximum is 64.

    .PARAMETER DisplayResolution
        Specifies the display resolution of the VM. Default is '1440x900'.
        Allowed values are: '640x480','800x600','1024x768','1152x864','1280x720',
        '1280x768','1280x800','1280x960','1280x1024','1360x768','1366x768',
        '1400x1050','1440x900','1600x900','1680x1050','1920x1080','1920x1200',
        '2560x1440','2560x1600','3840x2160','3840x2400','4096x2160'.

    .PARAMETER StartVM
        Specifies whether to start the VM after creation. Default is $true.

    .PARAMETER SwitchName
        Specifies the name of the virtual switch to connect the VM to. If not specified, an Out-GridView will be displayed to select a switch.
        If no switches are found, the VM will be created without a network connection.

    .PARAMETER VHDSizeGB
        Specifies the size of the VHD in whole number GB. Default is 64. Maximum is 128.

    .INPUTS
        None.

        You cannot pipe input to this cmdlet.

    .OUTPUTS
        None.

        This function does not return any output.

    .EXAMPLE
        New-OSDWorkspaceVM
        Creates a Hyper-V VM for use with OSDWorkspace

    .EXAMPLE
        New-OSDWorkspaceVM -CheckpointVM $false -Generation 2 -MemoryStartupGB 8 -NamePrefix 'MyVM' -ProcessorCount 4 -DisplayResolution '1920x1080' -StartVM $false -SwitchName 'MySwitch' -VHDSizeGB 50
        Creates a Generation 2 Hyper-V VM with 8GB of memory, 4 processors, 1920x1080 display resolution, and a 50GB VHD. The VM will not be started and will not have an Initial checkpoint created.

    .LINK
        https://github.com/OSDeploy/OSD.Workspace/blob/main/docs/New-OSDWorkspaceVM.md
    
    .NOTES
    David Segura
    #>

    [CmdletBinding()]
    param (
        [System.Boolean]
        $CheckpointVM = $true,

        [ValidateSet('1','2')]
        [System.UInt16]
        $Generation = 2,

        [ValidateRange(2, 64)]
        [System.UInt16]
        $MemoryStartupGB = 10,

        [System.String]
        $NamePrefix = 'OSDWorkspace',

        [ValidateRange(2, 64)]
        [System.UInt16]
        $ProcessorCount = 2,

        [ValidateSet('640x480','800x600','1024x768','1152x864','1280x720',
        '1280x768','1280x800','1280x960','1280x1024','1360x768','1366x768',
        '1400x1050','1440x900','1600x900','1680x1050','1920x1080','1920x1200',
        '2560x1440','2560x1600','3840x2160','3840x2400','4096x2160')]
        [System.String]
        $DisplayResolution = '1440x900',

        [System.Boolean]
        $StartVM = $true,

        [System.String]
        $SwitchName,

        [ValidateRange(8, 128)]
        [System.UInt16]
        $VHDSizeGB = 64
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
    # Is Hyper-V enabled?
    if (Test-IsHyperVEnabled) {
        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Hyper-V is enabled"
    }
    else {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Hyper-V is not enabled, or may not be compatible with this version of Windows. Try running the following elevated Admin command:"
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Enable-WindowsOptionalFeature -Online -FeatureName 'Microsoft-Hyper-V-All' -NoRestart"
        return
    }
    #=================================================
    # Can only make a VM matching the architecture of the running OS
    $Architecture = $Env:PROCESSOR_ARCHITECTURE
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Architecture = $Architecture"
    #=================================================
    # Do we have a Boot Media?
    $SelectWinPEBuild = $null
    $SelectWinPEBuild = Select-OSDWSWinPEBuild -Architecture $Architecture
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] SelectWinPEBuild: $SelectWinPEBuild"

    if ($null -eq $SelectWinPEBuild) {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] No OSDWorkspace BootMedia was found or selected"
        return
    }
    #=================================================
    # Get Hyper-V Defaults
    #$VMManagementService = Get-WmiObject -Namespace root\virtualization\v2 Msvm_VirtualSystemManagementService
    $VMManagementServiceSettingData = Get-WmiObject -Namespace root\virtualization\v2 Msvm_VirtualSystemManagementServiceSettingData
    #=================================================
    # Set the Boot ISO
    # $DvdDrivePath = Join-Path $($SelectWinPEBuild.Path) 'BootMedia_NoPrompt.iso'
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Select a BootMedia ISO to use with this Virtual Machine (Cancel to exit)"
    $SelectDvdDrive = Get-ChildItem "$($SelectWinPEBuild.Path)\iso" *.iso | Sort-Object Name, FullName | Select-Object Name, FullName | Out-GridView -Title 'Select a BootMedia ISO to use with this Virtual Machine' -OutputMode Single
    if ($null -eq $SelectDvdDrive) {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] No BootMedia ISO was found"
        return
    }
    $DvdDrivePath = $SelectDvdDrive.FullName
    #=================================================
    # Select a Default Switch
    if (-not ($SwitchName)) {
        $GetVMSwitch = Get-VMSwitch -ErrorAction SilentlyContinue
        if ($GetVMSwitch.Count -ge 1) {
            Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Virtual Switch Name was not specified with the SwitchName parameter"
            $SwitchName = Get-VMSwitch | Select-Object Name, SwitchType, Id | Out-GridView -Title 'Select a Virtual Switch to use with this Virtual Machine (Cancel = Not connected)' -OutputMode Single | Select-Object -ExpandProperty Name
            Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] SwitchName: $SwitchName"
        }
        else {
            Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] No Virtual Switches found with Get-VMSwitch, you will have to create a Virtual Switch. Setting to Not connected"
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
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] MemoryStartupGB: $MemoryStartupGB"
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] The -MemoryStartupGB parameter is used to specify the amount of memory in GB to allocate to the VM"
    $MemoryStartupBytes = ($MemoryStartupGB * 1GB)
    #=================================================
    # Create VM VHD
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] New-VM: Creating Virtual Machine in (5 second delay)"
    Start-Sleep -Seconds 5
    if ($SwitchName) {
        $vm = New-VM -Name $VmName -Generation $Generation -MemoryStartupBytes $MemoryStartupBytes -NewVHDPath $VHDPath -NewVHDSizeBytes $VHDSizeBytes -SwitchName $SwitchName -ErrorAction Stop
    }
    else {
        $vm = New-VM -Name $VmName -Generation $Generation -MemoryStartupBytes $MemoryStartupBytes -NewVHDPath $VHDPath -NewVHDSizeBytes $VHDSizeBytes -ErrorAction Stop
    }
    #=================================================
    # Add DVD Drive
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Add-VMDvdDrive -Path $DvdDrivePath"
    $DvdDrive = $vm | Add-VMDvdDrive -Path $DvdDrivePath -Passthru
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Get-VMHardDiskDrive"
    $HardDiskDrive = $vm | Get-VMHardDiskDrive
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Get-VMNetworkAdapter"
    $NetworkAdapter = $vm | Get-VMNetworkAdapter
    #=================================================
    # Generation
    if ($Generation -eq 2) {
        # First Boot Device
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Set-VMFirmware -FirstBootDevice"
        $vm | Set-VMFirmware -FirstBootDevice $DvdDrive

        # Firmware
        #$vm | Set-VMFirmware -BootOrder $DvdDrive, $vmHardDiskDrive, $vmNetworkAdapter -Verbose

        # Security
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Set-VMFirmware -EnableSecureBoot On"
        $vm | Set-VMFirmware -EnableSecureBoot On
        if ((Get-TPM).TpmPresent -eq $true -and (Get-TPM).TpmReady -eq $true) {
            Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Set-VMSecurity -VirtualizationBasedSecurityOptOut:`$false"
            $vm | Set-VMSecurity -VirtualizationBasedSecurityOptOut:$false
            Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Set-VMKeyProtector -NewLocalKeyProtector"
            $vm | Set-VMKeyProtector -NewLocalKeyProtector
            Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Enable-VMTPM"
            $vm | Enable-VMTPM
        }
    }
    #=================================================
    # Memory
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Set-VMMemory -DynamicMemoryEnabled False"
    $vm | Set-VMMemory -DynamicMemoryEnabled $false
    #=================================================
    # Processor
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] ProcessorCount: $ProcessorCount"
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] The -ProcessorCount parameter is used to set the number of processors to allocate to the VM. Default is 2"
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Set-VMProcessor -Count $($ProcessorCount)"
    $vm | Set-VMProcessor -Count $ProcessorCount
    #=================================================
    # Display Resolution
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] DisplayResolution: $DisplayResolution"
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] The -DisplayResolution parameter is used to set the resolution of the Virtual Machine. Default is 1440x900"
    $HorizontalResolution = $DisplayResolution.Split('x')[0]
    $VerticalResolution = $DisplayResolution.Split('x')[1]
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Set-VMVideo -HorizontalResolution $($HorizontalResolution) -VerticalResolution $($VerticalResolution) -ResolutionType Single"
    $vm | Set-VMVideo -HorizontalResolution $HorizontalResolution -VerticalResolution $VerticalResolution -ResolutionType Single
    #=================================================
    # Integration Services
    # Thanks Andreas Landry
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Enable-VMIntegrationService"
    $IntegrationService = Get-VMIntegrationService -VMName $vm.Name | Where-Object { $_ -match 'Microsoft:[0-9A-Fa-f]{8}[-][0-9A-Fa-f]{4}[-][0-9A-Fa-f]{4}[-][0-9A-Fa-f]{4}[-][0-9A-Fa-f]{12}\\6C09BB55-D683-4DA0-8931-C9BF705F6480' }
    $vm | Get-VMIntegrationService -Name $IntegrationService.Name | Enable-VMIntegrationService
    #=================================================
    # Checkpoints Start Stop
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Set-VM -AutomaticCheckpointsEnabled `$false -AutomaticStartAction Nothing -AutomaticStartDelay 3 -AutomaticStopAction Shutdown"
    $vm | Set-VM -AutomaticCheckpointsEnabled $false -AutomaticStartAction Nothing -AutomaticStartDelay 3 -AutomaticStopAction Shutdown
    #=================================================
    # Create a Snapshot
    if ($CheckpointVM -eq $true) {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Checkpoint-VM -SnapshotName 'New-VM'"
        $vm | Checkpoint-VM -SnapshotName 'New-VM'
    }
    #=================================================
    # Export Final Configuration
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Exporting current configuration to $($SelectWinPEBuild.Path)\vm.json"
    $vm | ConvertTo-Json -Depth 5 | Out-File -FilePath "$($SelectWinPEBuild.Path)\vm.json" -Force
    #=================================================
    # Start VM
    if ($StartVM -eq $true) {
        Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] vmconnect.exe `"$($env:ComputerName) $VmName`""
        vmconnect.exe $env:ComputerName $VmName
        Start-Sleep -Seconds 10
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start-VM"
        $vm | Start-VM
    }
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}
Register-ArgumentCompleter -CommandName New-OSDWorkspaceVM -ParameterName 'SwitchName' -ScriptBlock {Get-VMSwitch | Select-Object -ExpandProperty Name | ForEach-Object {if ($_.Contains(' ')) {"'$_'"} else {$_}}}