---
external help file: OSD.Workspace-help.xml
Module Name: OSD.Workspace
online version:
schema: 2.0.0
---

# Get-OSDWorkspace

## SYNOPSIS
Displays information about the OSD.Workspace PowerShell Module and initializes the environment.

## SYNTAX

```
Get-OSDWorkspace [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
The Get-OSDWorkspace function displays comprehensive information about the OSD.Workspace PowerShell Module, 
including module version, team information, upcoming events, and links to resources and documentation.

This function performs the following operations:
1.
Initializes the OSDWorkspace environment
2.
Displays team information and contact links
3.
Shows upcoming community events
4.
Lists important resources and documentation links
5.
Displays version information for various components

This function is typically run when first starting to work with OSD.Workspace to verify
the module is properly installed and to access important resources.

## EXAMPLES

### EXAMPLE 1
```
Get-OSDWorkspace
```

Displays information about the OSD.Workspace PowerShell Module and initializes the environment.

### EXAMPLE 2
```
Get-OSDWorkspace -Verbose
```

Displays information about the OSD.Workspace PowerShell Module with additional verbose output 
showing initialization steps and path information.

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

### System.Management.Automation.PSCustomObject
### Returns the OSDWorkspace configuration object that contains paths, settings, and other information.
## NOTES
Author: David Segura
Version: 1.0
Date: April 29, 2025

This function calls Initialize-OSDWorkspace internally to set up the environment.

## RELATED LINKS
