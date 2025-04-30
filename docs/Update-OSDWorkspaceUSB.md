---
external help file: OSD.Workspace-help.xml
Module Name: OSD.Workspace
online version:
schema: 2.0.0
---

# Update-OSDWorkspaceUSB

## SYNOPSIS
Updates an existing OSDWorkspace USB drive with new WinPE boot media files.

## SYNTAX

```
Update-OSDWorkspaceUSB [[-BootLabel] <String>] [[-DataLabel] <String>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
The Update-OSDWorkspaceUSB function refreshes an existing OSDWorkspace bootable USB drive 
with updated WinPE boot media files from a selected OSDWorkspace WinPE Build.

This function performs the following operations:
1.
Validates administrator privileges
2.
Prompts for selection of a WinPE Build using Select-OSDWSWinPEBuild
3.
Prompts for selection of a Media type (WinPE-Media or WinPE-MediaEX)
4.
Disables Autorun for the USB drive
5.
Locates existing USB volumes labeled 'USB-WinPE'
6.
Copies the selected WinPE media files to the bootable partition
7.
Creates a BootMedia.json file with build information

No partitioning or formatting is performed, as this function is designed to update 
an existing USB drive that was previously created with New-OSDWorkspaceUSB.

## EXAMPLES

### EXAMPLE 1
```
Update-OSDWorkspaceUSB
```

Updates an existing OSDWorkspace USB drive with the selected OSDWorkspace WinPE Build.
Uses the default labels 'USB-WinPE' for boot partition and 'USB-DATA' for data partition.

### EXAMPLE 2
```
Update-OSDWorkspaceUSB -BootLabel 'BOOT' -DataLabel 'DATA'
```

Updates an existing OSDWorkspace USB drive with the selected OSDWorkspace WinPE Build.
Uses the custom labels 'BOOT' for boot partition and 'DATA' for data partition.

### EXAMPLE 3
```
Update-OSDWorkspaceUSB -Verbose
```

Updates an existing OSDWorkspace USB drive with detailed verbose output showing each step of the process.

## PARAMETERS

### -BootLabel
Specifies the volume label for the boot partition.
Default value is 'USB-WinPE'.
Maximum length is 11 characters due to FAT32 filesystem limitations.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: USB-WinPE
Accept pipeline input: False
Accept wildcard characters: False
```

### -DataLabel
Specifies the volume label for the data partition.
Default value is 'USB-DATA'.
Maximum length is 32 characters due to NTFS filesystem limitations.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: USB-DATA
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

### Microsoft.Management.Infrastructure.CimInstance#root/Microsoft/Windows/Storage/MSFT_Disk
### Returns the updated USB disk object.
## NOTES
Author: David Segura
Version: 1.0
Date: April 2025

Prerequisites:
    - PowerShell 5.0 or higher
    - Windows 10 or higher
    - Run as Administrator
    - An existing OSDWorkspace USB drive created with New-OSDWorkspaceUSB
    - At least one WinPE build available in the OSDWorkspace

The function searches for USB volumes labeled 'USB-WinPE' to update.
If no matching 
volumes are found, the function will display a warning and exit.

## RELATED LINKS
