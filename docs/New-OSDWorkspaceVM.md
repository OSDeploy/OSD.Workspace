---
external help file: OSD.Workspace-help.xml
Module Name: OSD.Workspace
online version: https://github.com/OSDeploy/OSD.Workspace/blob/main/docs/New-OSDWorkspaceVM.md
schema: 2.0.0
---

# New-OSDWorkspaceVM

## SYNOPSIS
Creates a Hyper-V VM for use with OSDWorkspace

## SYNTAX

```
New-OSDWorkspaceVM [[-CheckpointVM] <Boolean>] [[-Generation] <UInt16>] [[-MemoryStartupGB] <UInt16>]
 [[-NamePrefix] <String>] [[-ProcessorCount] <UInt16>] [[-DisplayResolution] <String>] [[-StartVM] <Boolean>]
 [[-SwitchName] <String>] [[-VHDSizeGB] <UInt16>] [<CommonParameters>]
```

## DESCRIPTION
Creates a Hyper-V VM for use with OSDWorkspace

## EXAMPLES

### EXAMPLE 1
```
New-OSDWorkspaceVM
```

Creates a Hyper-V VM for use with OSDWorkspace

### EXAMPLE 2
```
New-OSDWorkspaceVM -CheckpointVM $false -Generation 2 -MemoryStartupGB 8 -NamePrefix 'MyVM' -ProcessorCount 4 -DisplayResolution '1920x1080' -StartVM $false -SwitchName 'MySwitch' -VHDSizeGB 50
```

Creates a Generation 2 Hyper-V VM with 8GB of memory, 4 processors, 1920x1080 display resolution, and a 50GB VHD.
The VM will not be started and will not have an Initial checkpoint created.

## PARAMETERS

### -CheckpointVM
Specifies whether to create a checkpoint of the VM after creation.
Default is $true.

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
Specifies the generation of the VM.
Default is 2.

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
Specifies the amount of memory in whole number GB to allocate to the VM.
Default is 10.
Maximum is 64.

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
Specifies the prefix to use for the VM name.
Default is 'OSDWorkspace'.
Full VM name will be in the format 'yyMMdd-HHmmss 'NamePrefix' BootMediaName'.

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
Specifies the number of processors to allocate to the VM.
Default is 2.
Maximum is 64.

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
Default is '1440x900'.
Allowed values are: '640x480','800x600','1024x768','1152x864','1280x720',
'1280x768','1280x800','1280x960','1280x1024','1360x768','1366x768',
'1400x1050','1440x900','1600x900','1680x1050','1920x1080','1920x1200',
'2560x1440','2560x1600','3840x2160','3840x2400','4096x2160'.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: 1440x900
Accept pipeline input: False
Accept wildcard characters: False
```

### -StartVM
Specifies whether to start the VM after creation.
Default is $true.

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
If not specified, an Out-GridView will be displayed to select a switch.
If no switches are found, the VM will be created without a network connection.

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
Specifies the size of the VHD in whole number GB.
Default is 64.
Maximum is 128.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None.
### You cannot pipe input to this cmdlet.
## OUTPUTS

### None.
### This function does not return any output.
## NOTES
David Segura

## RELATED LINKS

[https://github.com/OSDeploy/OSD.Workspace/blob/main/docs/New-OSDWorkspaceVM.md](https://github.com/OSDeploy/OSD.Workspace/blob/main/docs/New-OSDWorkspaceVM.md)

