---
external help file: OSD.Workspace-help.xml
Module Name: OSD.Workspace
online version: https://learn.microsoft.com/en-us/windows-hardware/get-started/adk-install
schema: 2.0.0
---

# Update-OSDWorkspaceSubmodule

## SYNOPSIS
Updates all submodules in the OSDWorkspace repository to their latest commits.

## SYNTAX

```
Update-OSDWorkspaceSubmodule [-Force] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
The Update-OSDWorkspaceSubmodule function updates all Git submodules in the OSDWorkspace repository
(typically located at C:\OSDWorkspace\submodules) to their latest commits from the remote repositories.

This function performs the following operations:
1.
Validates administrator privileges
2.
Navigates to the OSDWorkspace repository root
3.
Executes 'git submodule update --remote --merge' to update all submodules to the latest commits
4.
Returns to the original location

The -Force parameter is required to perform the update operation to prevent accidental updates.

If you have not added a repository as a submodule yet, use Add-OSDWorkspaceSubmodule first.

## EXAMPLES

### EXAMPLE 1
```
Update-OSDWorkspaceSubmodule -Force
```

Updates all submodules in the OSDWorkspace repository to their latest commits.

### EXAMPLE 2
```
Update-OSDWorkspaceSubmodule -Force -Verbose
```

Updates all submodules with detailed output showing each step of the process.

## PARAMETERS

### -Force
Required switch parameter to confirm that you want to update all submodules.
This is a safety measure to prevent accidentally updating submodules.

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

This function modifies existing submodules by updating them to the latest commit from their respective repositories.

For more information about Git submodules, see:
    https://git-scm.com/docs/git-submodule
    https://git-scm.com/book/en/v2/Git-Tools-Submodules

## RELATED LINKS
