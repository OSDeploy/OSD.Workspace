---
external help file: OSD.Workspace-help.xml
Module Name: OSD.Workspace
online version:
schema: 2.0.0
---

# New-OSDWorkspaceUSB

## SYNOPSIS
Creates a new OSDWorkspace USB bootable drive with WinPE boot media.

## SYNTAX

```
New-OSDWorkspaceUSB [[-BootLabel] <String>] [[-DataLabel] <String>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
The New-OSDWorkspaceUSB function creates a new bootable USB drive from a selected 
OSDWorkspace WinPE Build.
This function prepares the USB drive for booting into WinPE 
by partitioning, formatting, and copying necessary boot files.

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
Prompts for selection of a USB drive that meets size requirements
6.
Clears all data from the selected USB drive (with confirmation)
7.
Initializes the disk with MBR partition style
8.
Creates and formats a 4GB FAT32 boot partition (active)
9.
Creates and formats an NTFS data partition using remaining space
10.
Copies the selected WinPE media files to the bootable partition

The function creates a dual-partition structure:
- A FAT32 bootable partition (4GB) containing WinPE boot files
- An NTFS data partition using the remaining space

## EXAMPLES

### EXAMPLE 1
```
New-OSDWorkspaceUSB
```

Creates a new OSDWorkspace USB with default labels for boot and data partitions.
Uses 'USB-WinPE' for the boot partition and 'USB-DATA' for the data partition.

### EXAMPLE 2
```
New-OSDWorkspaceUSB -BootLabel 'BOOT' -DataLabel 'OSDDATA'
```

Creates a new OSDWorkspace USB with custom labels for boot and data partitions.
Uses 'BOOT' for the boot partition and 'OSDDATA' for the data partition.

### EXAMPLE 3
```
New-OSDWorkspaceUSB -Verbose
```

Creates a new OSDWorkspace USB with detailed verbose output showing each step of the process.

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
### Returns the configured USB disk object.
## NOTES
Author: David Segura
Version: 1.0
Date: April 2025

Prerequisites:
    - PowerShell 5.0 or higher
    - Windows 10 or higher (Windows 11 recommended)
    - Windows 10 build 1703 or higher
    - Run as Administrator
    - At least one WinPE build available in the OSDWorkspace
    - USB drive with minimum capacity of 7GB

WARNING: This function will erase ALL data on the selected USB drive.
A confirmation prompt will be displayed before erasing the drive.

For drives larger than 2TB, the current GPT implementation is commented out
as it is not working as expected for bootable drives.

## RELATED LINKS
