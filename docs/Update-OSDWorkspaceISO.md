---
external help file: OSD.Workspace-help.xml
Module Name: OSD.Workspace
online version: https://learn.microsoft.com/en-us/windows-hardware/get-started/adk-install
schema: 2.0.0
---

# Update-OSDWorkspaceISO

## SYNOPSIS
Updates or creates a bootable OSD Workspace ISO using the Windows ADK and available WinPE builds.

## SYNTAX

```
Update-OSDWorkspaceISO [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
This function prepares and updates a bootable ISO for the OSD Workspace environment.
It checks for required prerequisites, verifies and manages the Windows ADK installation or cache, and allows selection of the appropriate ADK version if multiple are available.
The function also enables selection of a WinPE build, sets up build variables, and initiates the ISO creation process.
It is intended for use on Windows 10 or higher, requires PowerShell 5.0 or above, and must be run as Administrator.

## EXAMPLES

### EXAMPLE 1
```
Update-OSDWorkspaceISO
Runs the function to update or create the OSD Workspace ISO using the available ADK and WinPE builds.
```

## PARAMETERS

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
Author: David Segura
Version: 1.0
Date: May 2025

Prerequisites:
  - PowerShell 5.0 or higher
  - Windows 10 or higher
  - Run as Administrator

## RELATED LINKS

[https://learn.microsoft.com/en-us/windows-hardware/get-started/adk-install](https://learn.microsoft.com/en-us/windows-hardware/get-started/adk-install)

