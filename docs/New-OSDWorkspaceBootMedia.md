---
external help file: OSD.Workspace-help.xml
Module Name: OSD.Workspace
online version: https://github.com/OSDeploy/OSD.Workspace/blob/main/docs/New-OSDWorkspaceBootMedia.md
schema: 2.0.0
---

# New-OSDWorkspaceBootMedia

## SYNOPSIS
Creates a new OSDWorkspace BootMedia.

## SYNTAX

### Default (Default)
```
New-OSDWorkspaceBootMedia -Name <String> [-Languages <String[]>] [-SetAllIntl <String>]
 [-SetInputLocale <String>] [-Timezone <String>] [-AdkSelect] [-AdkSkipOCs] [-Architecture <String>]
 [-UpdateUSB] [<CommonParameters>]
```

### ADK
```
New-OSDWorkspaceBootMedia -Name <String> [-Languages <String[]>] [-SetAllIntl <String>]
 [-SetInputLocale <String>] [-Timezone <String>] [-AdkSelect] [-AdkSkipOCs] [-AdkWinPE] -Architecture <String>
 [-UpdateUSB] [<CommonParameters>]
```

## DESCRIPTION
This function creates a new OSDWorkspace BootMedia by copying the selected BootImage and adding the Windows ADK Optional Components.
The BootMedia is created in the OSDWorkspace BootMedia directory.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Name
Name to append to the BootMedia Id.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: False
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
Default value: None
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
Default value: None
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
Accepted values: amd64, arm64

Required: False
Position: Named
Default value: En-US
Accept pipeline input: False
Accept wildcard characters: False
```

### -Timezone
Set the WinPE TimeZone.
Default is the current TimeZone.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: amd64, arm64

Required: False
Position: Named
Default value: (tzutil /g)
Accept pipeline input: False
Accept wildcard characters: False
```

### -AdkSelect
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

### -AdkSkipOCs
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

### -AdkWinPE
Uses the Windows ADK winpe.wim instead of an imported BootImage.

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

### -Architecture
Architecture of the BootImage.
This is automatically set when selected a existing BootImage.
This is required when using the Windows ADK winpe.wim.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### None.
### This function does not return any output.
## NOTES
David Segura

## RELATED LINKS

[https://github.com/OSDeploy/OSD.Workspace/blob/main/docs/New-OSDWorkspaceBootMedia.md](https://github.com/OSDeploy/OSD.Workspace/blob/main/docs/New-OSDWorkspaceBootMedia.md)

