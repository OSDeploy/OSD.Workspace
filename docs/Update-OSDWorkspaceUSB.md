---
external help file: OSD.Workspace-help.xml
Module Name: OSD.Workspace
online version: https://github.com/OSDeploy/OSD.Workspace/blob/main/docs/Update-OSDWorkspaceGitHubRepo.md
schema: 2.0.0
---

# Update-OSDWorkspaceUSB

## SYNOPSIS
Creates a new OSDWorkspace USB.

## SYNTAX

```
Update-OSDWorkspaceUSB [[-BootLabel] <String>] [[-DataLabel] <String>] [<CommonParameters>]
```

## DESCRIPTION
This function creates a new OSDWorkspace USB by selecting a boot media and performing necessary checks and operations.

## EXAMPLES

### EXAMPLE 1
```
New-OSDWorkspaceUSB
```

Creates a new OSDWorkspace USB with default labels for boot and data partitions.

### EXAMPLE 2
```
New-OSDWorkspaceUSB -BootLabel 'MYBOOT' -DataLabel 'MYDATA'
```

Creates a new OSDWorkspace USB with the boot label 'MYBOOT' and data label 'MYDATA'.

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
Default value: BootMedia
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
Position: 2
Default value: USB-Data
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
