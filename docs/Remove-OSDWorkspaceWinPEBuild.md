---
external help file: OSD.Workspace-help.xml
Module Name: OSD.Workspace
online version:
schema: 2.0.0
---

# Remove-OSDWorkspaceWinPEBuild

## SYNOPSIS
Removes one or more WinPE builds from the OSDWorkspace environment.

## SYNTAX

```
Remove-OSDWorkspaceWinPEBuild [-Architecture <String>] -Force [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
The Remove-OSDWorkspaceWinPEBuild function removes selected WinPE builds from the OSDWorkspace build directory 
(typically located at C:\OSDWorkspace\build\windows-pe) and associated build profile files from the cache.

This function performs the following operations:
1.
Validates administrator privileges
2.
Displays available WinPE builds in a grid view for selection (supports multiple selection)
3.
For each selected build:
   a.
Removes the build directory and all its contents
   b.
Removes any associated build profile files from the cache
4.
Updates the WinPE build index to reflect the changes

The -Force parameter is required to perform the deletion operation as a safety measure.

## EXAMPLES

### EXAMPLE 1
```
Remove-OSDWorkspaceWinPEBuild -Force
```

Displays all available WinPE builds for selection and removes the selected builds from the OSDWorkspace.

### EXAMPLE 2
```
Remove-OSDWorkspaceWinPEBuild -Architecture 'amd64' -Force
```

Displays only amd64 WinPE builds for selection and removes the selected builds.

### EXAMPLE 3
```
Remove-OSDWorkspaceWinPEBuild -Force -Verbose
```

Removes selected WinPE builds with detailed output showing each step of the process.

## PARAMETERS

### -Architecture
Optional parameter to filter builds by architecture (amd64, arm64).
If not specified, builds from all architectures will be displayed for selection.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
Required switch parameter to confirm that you want to delete the selected builds.
This is a safety measure to prevent accidental deletion of WinPE builds.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: True
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

### None

## OUTPUTS

### None. This function does not generate any output objects.

## NOTES
Author: David Segura
Version: 1.0
Date: September 22, 2025

Prerequisites:
    - PowerShell 5.0 or higher
    - Windows 10 or higher
    - The script must be run with administrator privileges.
    - WinPE builds must exist in the OSDWorkspace build directory.

This function permanently removes selected WinPE builds from the OSDWorkspace environment.
This is a destructive operation that cannot be undone except by restoring from a backup.

The function will also remove associated build profile files (.json) from the cache directory
if they match the name of the removed builds.

## RELATED LINKS