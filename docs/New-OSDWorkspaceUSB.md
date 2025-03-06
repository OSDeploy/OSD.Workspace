---
external help file: OSD.Workspace-help.xml
Module Name: OSD.Workspace
online version: https://github.com/OSDeploy/OSD.Workspace/blob/main/docs/New-OSDWorkspaceBootMedia.md
schema: 2.0.0
---

# New-OSDWorkspaceUSB

## SYNOPSIS
Creates a new OSDWorkspace USB.

## SYNTAX

```
New-OSDWorkspaceUSB [[-BootLabel] <String>] [[-DataLabel] <String>] [<CommonParameters>]
```

## DESCRIPTION
This function creates a new OSDWorkspace USB by selecting a boot media and performing necessary checks and operations.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -BootLabel
Label for the boot partition.
Default is 'WINPE'.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: WINPE
Accept pipeline input: False
Accept wildcard characters: False
```

### -DataLabel
Label for the data partition.
Default is 'USB Data'.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
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

### None

## OUTPUTS

### None.
### This function does not return any output.
## NOTES
David Segura

## RELATED LINKS
