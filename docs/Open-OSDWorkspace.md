---
external help file: OSD.Workspace-help.xml
Module Name: OSD.Workspace
online version: https://github.com/OSDeploy/OSD.Workspace/blob/main/docs/Open-OSDWorkspace.md
schema: 2.0.0
---

# Open-OSDWorkspace

## SYNOPSIS
Opens the OSDWorkspace in VS Code or the specified Application.

## SYNTAX

```
Open-OSDWorkspace [[-Application] <String>] [<CommonParameters>]
```

## DESCRIPTION
Opens the OSDWorkspace in VS Code or the specified Applications.

## EXAMPLES

### EXAMPLE 1
```
Open-OSDWorkspace
```

Opens the OSDWorkspace in Visual Studio Code.

### EXAMPLE 2
```
Open-OSDWorkspace -Application Explorer
```

Opens the OSDWorkspace in Windows Explorer.

### EXAMPLE 3
```
Open-OSDWorkspace -Application Terminal
```

Opens the OSDWorkspace in Windows Terminal.

## PARAMETERS

### -Application
The application to open the OSDWorkspace in.
Valid values are 'code', 'Explorer', and 'Terminal'.
Default is 'code'.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: Code
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

[https://github.com/OSDeploy/OSD.Workspace/blob/main/docs/Open-OSDWorkspace.md](https://github.com/OSDeploy/OSD.Workspace/blob/main/docs/Open-OSDWorkspace.md)

