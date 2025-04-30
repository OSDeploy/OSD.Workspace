---
external help file: OSD.Workspace-help.xml
Module Name: OSD.Workspace
online version:
schema: 2.0.0
---

# Update-OSDWorkspaceHelp

## SYNOPSIS
Generates and updates PowerShell help documentation for the OSD.Workspace module.

## SYNTAX

```
Update-OSDWorkspaceHelp [-Force] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
The Update-OSDWorkspaceHelp function generates and updates the PowerShell help documentation 
files for the OSD.Workspace module.
This includes creating or refreshing Markdown-based help 
files in the OSDWorkspace documentation directory (C:\OSDWorkspace\docs\powershell-help).

This function performs the following operations:
1.
Checks if the platyPS module is installed and installs it if needed
2.
Creates the destination directory for help files if it doesn't exist
3.
Generates help documentation for the OSD.Workspace module
4.
Optionally generates help documentation for the DISM module
5.
Writes the documentation files to the appropriate locations

When run without the -Force parameter, this function will only update help files
if they don't already exist.
Use -Force to regenerate all help files.

## EXAMPLES

### EXAMPLE 1
```
Update-OSDWorkspaceHelp
```

Checks if PowerShell help files exist for the OSD.Workspace module and creates them 
if they don't exist.

### EXAMPLE 2
```
Update-OSDWorkspaceHelp -Force
```

Regenerates all PowerShell help files for the OSD.Workspace module, 
overwriting any existing files.

### EXAMPLE 3
```
Update-OSDWorkspaceHelp -Verbose
```

Updates PowerShell help files with detailed verbose output showing each step of the process.

## PARAMETERS

### -Force
Switch parameter that forces regeneration of all help files, 
even if they already exist.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
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

### None. This function does not generate any output objects.
## NOTES
Author: David Segura
Version: 1.0
Date: April 29, 2025

Prerequisites:
    - PowerShell 5.0 or higher
    - Internet connection (to install platyPS module if needed)
    
The platyPS module is used to generate the help documentation.
This function may require an internet connection to install the platyPS module if it's not already installed.

## RELATED LINKS
