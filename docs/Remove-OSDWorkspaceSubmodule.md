---
external help file: OSD.Workspace-help.xml
Module Name: OSD.Workspace
online version:
schema: 2.0.0
---

# Remove-OSDWorkspaceSubmodule

## SYNOPSIS
Removes one or more Git submodules from the OSDWorkspace repository.

## SYNTAX

```
Remove-OSDWorkspaceSubmodule [-Force] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
The Remove-OSDWorkspaceSubmodule function removes selected Git submodules from the OSDWorkspace repository 
(typically located at C:\OSDWorkspace\submodules).

This function performs the following operations:
1.
Validates administrator privileges
2.
Prompts for selection of submodules to remove using Select-OSDWSSharedLibrary
3.
For each selected submodule:
   a.
Removes the submodule entry from .git/config using 'git submodule deinit'
   b.
Removes the submodule's files from .git/modules directory
   c.
Removes the submodule entry from .gitmodules and deletes the submodule directory using 'git rm'

The -Force parameter is required to perform the deletion operation as a safety measure.

## EXAMPLES

### EXAMPLE 1
```
Remove-OSDWorkspaceSubmodule -Force
```

Prompts for selection of submodules and then removes the selected submodules from the OSDWorkspace repository.

### EXAMPLE 2
```
Remove-OSDWorkspaceSubmodule -Force -Verbose
```

Removes selected submodules with detailed output showing each step of the process.

## PARAMETERS

### -Force
Required switch parameter to confirm that you want to delete the selected submodules.
This is a safety measure to prevent accidental deletion of submodules.

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
Date: April 2025

Prerequisites:
    - Git for Windows must be installed and available in the system's PATH.
(https://gitforwindows.org/)
    - PowerShell 7.5 or higher is recommended.
    - The script must be run with administrator privileges.
    - The target OSDWorkspace repository must have submodules already added.

This function permanently removes selected submodules from the OSDWorkspace repository.
This is a destructive operation that cannot be undone except by restoring from a backup.

For more information about Git submodules, see:
    https://git-scm.com/docs/git-submodule
    https://git-scm.com/book/en/v2/Git-Tools-Submodules

## RELATED LINKS
