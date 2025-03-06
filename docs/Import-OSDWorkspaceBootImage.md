---
external help file: OSD.Workspace-help.xml
Module Name: OSD.Workspace
online version: https://github.com/OSDeploy/OSD.Workspace/blob/main/docs/Import-OSDWorkspaceBootImage.md
schema: 2.0.0
---

# Import-OSDWorkspaceBootImage

## SYNOPSIS
Imports the winre.wim from a mounted Windows Installation Media ISO to the OSDWorkspace BootImage directory.

## SYNTAX

```
Import-OSDWorkspaceBootImage [<CommonParameters>]
```

## DESCRIPTION
Imports the winre.wim from a mounted Windows Installation Media ISO to the OSDWorkspace BootImage directory.
Supports both Windows 11 24H2 amd64 and arm64 Windows Installation Media ISO.
Will display a Out-GridView of the available Indexes for each Mounted Windows Installation Media ISO.
Select one or multiple Indexes to import.
The BootImage will be imported to the OSDWorkspace BootImage directory with a name of the format "yyMMdd-HHmmss Architecture".

## EXAMPLES

### EXAMPLE 1
```
Import-OSDWorkspaceBootImage
```

Imports the winre.wim from a mounted Windows Installation Media ISO to the OSDWorkspace BootImage directory.

## PARAMETERS

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

[https://github.com/OSDeploy/OSD.Workspace/blob/main/docs/Import-OSDWorkspaceBootImage.md](https://github.com/OSDeploy/OSD.Workspace/blob/main/docs/Import-OSDWorkspaceBootImage.md)

