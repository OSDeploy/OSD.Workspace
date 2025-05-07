---
external help file: OSD.Workspace-help.xml
Module Name: OSD.Workspace
online version:
schema: 2.0.0
---

# New-OSDWorkspaceVM

## SYNOPSIS
Creates a customized Hyper-V virtual machine from selected OSDWorkspace WinPE build media.

## SYNTAX

```
New-OSDWorkspaceVM [[-CheckpointVM] <Boolean>] [[-Generation] <UInt16>] [[-MemoryStartupGB] <UInt16>]
 [[-NamePrefix] <String>] [[-ProcessorCount] <UInt16>] [[-DisplayResolution] <String>] [[-StartVM] <Boolean>]
 [[-SwitchName] <String>] [[-VHDSizeGB] <UInt16>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
The New-OSDWorkspaceVM function creates a Hyper-V virtual machine that boots from the selected
OSDWorkspace WinPE build media.
This VM can be used for testing WinPE deployments, scripts, 
and other OSD tools in a virtualized environment.

This function performs the following operations:
1.
Validates that Hyper-V is available on the system
2.
Prompts for selection of a WinPE build using Select-OSDWSWinPEBuild
3.
Prompts for selection of a Media type (WinPE-Media or WinPE-MediaEX)
4.
Creates a new Hyper-V VM with specified parameters
5.
Configures secure boot, TPM, and other settings based on the VM generation
6.
Mounts the selected ISO to the VM's DVD drive
7.
Optionally creates an initial checkpoint
8.
Optionally starts the VM

The VM is highly customizable with options for memory, CPU, networking, display resolution,
and storage configuration.

## EXAMPLES

### EXAMPLE 1
```
New-OSDWorkspaceVM
```

Creates a Hyper-V VM with default settings (Generation 2, 4GB RAM, 2 CPUs, 20GB VHD),
prompting for WinPE build selection.

### EXAMPLE 2
```
New-OSDWorkspaceVM -NamePrefix 'TestDeploy' -MemoryStartupGB 8 -ProcessorCount 4 -VHDSizeGB 50
```

Creates a customized Hyper-V VM with the name prefix 'TestDeploy', 8GB of RAM,
4 processors, and a 50GB virtual hard disk.

### EXAMPLE 3
```
New-OSDWorkspaceVM -CheckpointVM $false -Generation 2 -MemoryStartupGB 8 -NamePrefix 'MyVM' -ProcessorCount 4 -DisplayResolution '1920x1080' -StartVM $false -SwitchName 'MySwitch' -VHDSizeGB 50
```

Creates a Generation 2 Hyper-V VM with 8GB of memory, 4 processors, 1920x1080 display resolution,
and a 50GB VHD.
The VM will not be started automatically and will not have an initial checkpoint created.

## PARAMETERS

### -CheckpointVM
Specifies whether to create a checkpoint of the VM after creation.
Default value is $true.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: True
Accept pipeline input: False
Accept wildcard characters: False
```

### -Generation
Specifies the Hyper-V VM generation to create.
Valid values are 1 or 2.
Default value is 2.
Generation 1 VMs support legacy BIOS, while Generation 2 VMs support UEFI and secure boot.

```yaml
Type: UInt16
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: 2
Accept pipeline input: False
Accept wildcard characters: False
```

### -MemoryStartupGB
Specifies the amount of startup memory for the VM in gigabytes.
Default value is 4.

```yaml
Type: UInt16
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: 10
Accept pipeline input: False
Accept wildcard characters: False
```

### -NamePrefix
Specifies a prefix for the VM name.
The actual VM name will be in the format "NamePrefix-yyyy-MM-dd-HHmmss".
Default value is 'OSDWS'.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: OSDWorkspace
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProcessorCount
Specifies the number of virtual processors to allocate to the VM.
Default value is 2.

```yaml
Type: UInt16
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: 2
Accept pipeline input: False
Accept wildcard characters: False
```

### -DisplayResolution
Specifies the display resolution of the VM.
Valid values include '1024x768', '1280x720', '1280x768', '1280x800', '1280x960', '1280x1024', 
'1360x768', '1366x768', '1600x900', '1600x1200', '1680x1050', '1920x1080', and '1920x1200'.
Default value is '1280x720'.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: 1600x900
Accept pipeline input: False
Accept wildcard characters: False
```

### -StartVM
Specifies whether to start the VM after creation.
Default value is $true.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: True
Accept pipeline input: False
Accept wildcard characters: False
```

### -SwitchName
Specifies the name of the virtual switch to connect the VM to.
Default value is 'Default Switch'.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -VHDSizeGB
Specifies the size of the virtual hard disk in gigabytes.
Default value is 20.

```yaml
Type: UInt16
Parameter Sets: (All)
Aliases:

Required: False
Position: 9
Default value: 64
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProgressAction
{{ Fill ProgressAction Description }}

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### Microsoft.HyperV.PowerShell.VirtualMachine
### Returns the created Hyper-V virtual machine object.
## NOTES
Author: David Segura
Version: 1.0
Date: April 29, 2025

Prerequisites:
    - PowerShell 5.0 or higher
    - Windows 10/11 Pro, Enterprise, or Server with Hyper-V role installed
    - Run as Administrator
    - At least one WinPE build available in the OSDWorkspace
    
This function requires the Hyper-V PowerShell module to be installed and available.

## RELATED LINKS
