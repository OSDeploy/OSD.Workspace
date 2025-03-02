---
external help file: OSD.Workspace-help.xml
Module Name: OSD.Workspace
online version: https://github.com/OSDeploy/OSD.Workspace/blob/main/docs/Update-OSDWorkspaceGitHubRepo.md
schema: 2.0.0
---

# Update-OSDWorkspaceGitHubRepo

## SYNOPSIS
Updates a GitHub Repository in C:\OSDWorkspace\Library-GitHub from the GitHub Origin

## SYNTAX

```
Update-OSDWorkspaceGitHubRepo [-Force] [<CommonParameters>]
```

## DESCRIPTION
This function updates ALL GitHub repositories in the OSDWorkspace Library-GitHub directory.
The function will update this Git repository to the latest GitHub commit in the main branch.
It performs a fetch and clean operation to ensure the repository is up to date and free of untracked files.
If you have not cloned the repository, use Import-OSDWorkspaceGitHubRepo to clone it.

## EXAMPLES

### EXAMPLE 1
```
Update-OSDWorkspaceGitHubRepo -Force
```

Updates all GitHub repositories in the OSDWorkspace Library-GitHub directory to the latest GitHub commit in the main branch.

## PARAMETERS

### -Force
The -Force switch is Required to update the GitHub repository.
This will overwrite any local changes to the repository.

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

### None.
### You cannot pipe input to this cmdlet.
## OUTPUTS

### None.
### This function does not return any output.
## NOTES
David Segura

## RELATED LINKS

[https://github.com/OSDeploy/OSD.Workspace/blob/main/docs/Update-OSDWorkspaceGitHubRepo.md](https://github.com/OSDeploy/OSD.Workspace/blob/main/docs/Update-OSDWorkspaceGitHubRepo.md)

