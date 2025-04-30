---
external help file: OSD.Workspace-help.xml
Module Name: OSD.Workspace
online version:
schema: 2.0.0
---

# Import-OSDWorkspaceWinOS

## SYNOPSIS
Imports Windows Recovery Environment (WinRE) images from mounted Windows installation media to OSDWorkspace.

## SYNTAX

```
Import-OSDWorkspaceWinOS [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
The Import-OSDWorkspaceWinOS function extracts and imports Windows Recovery Environment (WinRE) images 
from mounted Windows installation media ISO files to the OSDWorkspace BootImage directory.

This function performs the following operations:
1.
Validates administrator privileges
2.
Scans for mounted Windows installation media ISO files
3.
Displays an Out-GridView selection dialog for available installation indexes
4.
Extracts the winre.wim file from the selected installation image(s)
5.
Imports the WinRE image(s) to the OSDWorkspace BootImage directory

The imported images are stored with a naming convention of "yyMMdd-HHmm Architecture" 
(e.g., "250429-1545 amd64") to indicate when they were imported and for which architecture.

This function supports both Windows 11 amd64 (x64) and arm64 installation media.

## EXAMPLES

### EXAMPLE 1
```
Import-OSDWorkspaceWinOS
```

Scans for mounted Windows installation media ISO files and presents a selection dialog
to choose which Windows version(s) to import WinRE from.

### EXAMPLE 2
```
Import-OSDWorkspaceWinOS -Verbose
```

Imports WinRE images with detailed verbose output showing each step of the extraction
and import process.

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

### None
### This function does not accept pipeline input.
## OUTPUTS

### None
### This function does not generate any output objects.
## NOTES
Author: David Segura
Version: 1.0
Date: April 29, 2025

Prerequisites:
    - PowerShell 5.0 or higher
    - Windows 10 or higher
    - Run as Administrator
    - Windows installation media ISO mounted (via File Explorer or third-party tools)
    
The WinRE images extracted are used as source images for creating custom WinPE boot media
with the Build-OSDWorkspaceWinPE function.

## RELATED LINKS
