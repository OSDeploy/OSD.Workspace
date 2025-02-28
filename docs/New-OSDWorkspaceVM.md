---
external help file: OSD.Workspace-help.xml
Module Name: OSD.Workspace
online version:
schema: 2.0.0
---

# New-OSDWorkspaceVM

## SYNOPSIS
Creates a Hyper-V VM for use with OSDWorkspace

## SYNTAX

```
New-OSDWorkspaceVM [[-CheckpointVM] <Boolean>] [[-Generation] <UInt16>] [[-MemoryStartupGB] <UInt16>]
 [[-NamePrefix] <String>] [[-ProcessorCount] <UInt16>] [[-DisplayResolution] <String>] [[-StartVM] <Boolean>]
 [[-SwitchName] <String>] [[-VHDSizeGB] <UInt16>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Creates a Hyper-V VM for use with OSDWorkspace

## EXAMPLES

### EXAMPLE 1
```
New-OSDWorkspaceVM
```

## PARAMETERS

### -CheckpointVM
{{ Fill CheckpointVM Description }}

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
{{ Fill Generation Description }}

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
{{ Fill MemoryStartupGB Description }}

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
{{ Fill NamePrefix Description }}

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
{{ Fill ProcessorCount Description }}

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
{{ Fill DisplayResolution Description }}

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
{{ Fill StartVM Description }}

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
{{ Fill SwitchName Description }}

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
{{ Fill VHDSizeGB Description }}

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

## NOTES
David Segura

## RELATED LINKS
