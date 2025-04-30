---
external help file: OSD.Workspace-help.xml
Module Name: OSD.Workspace
online version:
schema: 2.0.0
---

# Build-OSDWorkspaceWinPE

## SYNOPSIS
Creates a new customized WinPE build in the OSDWorkspace environment.

## SYNTAX

### Default (Default)
```
Build-OSDWorkspaceWinPE -Name <String> [-Architecture <String>] [-Languages <String[]>] [-SetAllIntl <String>]
 [-SetInputLocale <String>] [-SetTimeZone <String>] [-UpdateUSB] [-AdkSelectCacheVersion] [-AdkSkipOcPackages]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### ADK
```
Build-OSDWorkspaceWinPE -Name <String> -Architecture <String> [-Languages <String[]>] [-SetAllIntl <String>]
 [-SetInputLocale <String>] [-SetTimeZone <String>] [-UpdateUSB] [-AdkSelectCacheVersion] [-AdkSkipOcPackages]
 [-AdkUseWinPE] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
The Build-OSDWorkspaceWinPE function creates a new Windows Preinstallation Environment (WinPE) build 
in the OSDWorkspace build directory.
The function can use either a WinRE source image or the Windows 
Assessment and Deployment Kit (ADK) WinPE image as a base, then applies customizations including drivers,
packages, scripts, and other settings.

This function performs the following operations:
1.
Validates administrator privileges
2.
Creates necessary directory structure for the build
3.
Sources a base WinPE image (from WinRE or Windows ADK)
4.
Applies selected customizations (drivers, packages, scripts)
5.
Generates boot media in various formats (WIM, ISO, USB-ready files)

Build output is stored in the C:\OSDWorkspace\Build\WinPE directory by default,
organized by architecture and build name.

## EXAMPLES

### EXAMPLE 1
```
Build-OSDWorkspaceWinPE -Name 'MyBootMedia' -Architecture 'amd64'
```

Creates a new WinPE build for x64 architecture named 'MyBootMedia' using WinRE as the source.

### EXAMPLE 2
```
Build-OSDWorkspaceWinPE -Name 'MyBootMedia' -Architecture 'arm64'
```

Creates a new WinPE build for ARM64 architecture named 'MyBootMedia' using WinRE as the source.

### EXAMPLE 3
```
Build-OSDWorkspaceWinPE -Name 'MyBootMedia' -Architecture 'amd64' -AdkUseWinPE
```

Creates a new WinPE build for x64 architecture named 'MyBootMedia' using the Windows ADK WinPE image.

### EXAMPLE 4
```
Build-OSDWorkspaceWinPE -Name 'MyBootMedia' -Architecture 'arm64' -AdkSelectCacheVersion
```

Creates a new WinPE build for ARM64 architecture named 'MyBootMedia' and prompts to select 
which Windows ADK version to use as the source.

### EXAMPLE 5
```
Build-OSDWorkspaceWinPE -Name 'DeploymentMedia' -Verbose
```

Creates a new WinPE build with detailed verbose output showing each step of the process.

## PARAMETERS

### -Name
Specifies a friendly name for the WinPE build.
This name will be used in the build directory structure and media labels.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Architecture
Specifies the processor architecture for the WinPE build.
Valid values are 'amd64' (64-bit x86) and 'arm64' (64-bit ARM).
Default value is 'amd64'.

```yaml
Type: String
Parameter Sets: Default
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: String
Parameter Sets: ADK
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Languages
Windows ADK Languages to add to the BootImage.
Default is en-US.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: En-US
Accept pipeline input: False
Accept wildcard characters: False
```

### -SetAllIntl
Sets all International settings in WinPE to the specified language.
Default is en-US.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: En-US
Accept pipeline input: False
Accept wildcard characters: False
```

### -SetInputLocale
Sets the default InputLocale in WinPE to the specified Input Locale.
Default is en-US.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: En-US
Accept pipeline input: False
Accept wildcard characters: False
```

### -SetTimeZone
Set the WinPE SetTimeZone.
Default is the current SetTimeZone.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: (tzutil /g)
Accept pipeline input: False
Accept wildcard characters: False
```

### -UpdateUSB
Update a OSDWorkspace USB drive with the new BootMedia.

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

### -AdkSelectCacheVersion
Select the Windows ADK version to use if multiple versions are present in the cache.

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

### -AdkSkipOcPackages
Skip adding the Windows ADK Optional Components.
Useful for quick testing of the Library.

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

### -AdkUseWinPE
Uses the Windows ADK winpe.wim instead of an imported winre.wim.

```yaml
Type: SwitchParameter
Parameter Sets: ADK
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

## OUTPUTS

### None. This function does not generate any output objects.
## NOTES
Author: David Segura
Version: 1.0
Date: April 29, 2025

Prerequisites:
    - PowerShell 5.0 or higher
    - Windows 10 or higher
    - Run as Administrator
    - Windows ADK installed (if using -AdkUseWinPE or -AdkSelectCacheVersion)
    - WinRE source imported (if not using -AdkUseWinPE)
    
The build process can take several minutes depending on the customizations applied.

## RELATED LINKS
