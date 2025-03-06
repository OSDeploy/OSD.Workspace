---
external help file: OSD.Workspace-help.xml
Module Name: OSD.Workspace
online version: https://github.com/OSDeploy/OSD.Workspace/blob/main/docs/Import-OSDWorkspaceGitHubRepo.md
schema: 2.0.0
---

# Import-OSDWorkspaceGitHubRepo

## SYNOPSIS
Clones a GitHub Repository into C:\OSDWorkspace\Library-GitHub

## SYNTAX

```
Import-OSDWorkspaceGitHubRepo [-Url] <Uri> [<CommonParameters>]
```

## DESCRIPTION
This function clones a specified GitHub repository into the OSDWorkspace Library-GitHub directory.
Performs a fetch and clean operation to ensure the repository is up to date and free of untracked files.
If you have already cloned the repository, use the Update-OSDWorkspaceGitHubRepo cmdlet to update it.

## EXAMPLES

### EXAMPLE 1
```
Import-OSDWorkspaceGitHubRepo -Url 'https://github.com/MichaelEscamilla/OSDWorkspace-MichaelEscamilla.git'
```

Clones the repository 'OSDWorkspace-MichaelEscamilla' into the OSDWorkspace Library-GitHub directory.
#TODO Update URL to the OSDWorkspace Template GitHub Repository

## PARAMETERS

### -Url
The HTTPS URL of the GitHub repository to clone.

```yaml
Type: Uri
Parameter Sets: (All)
Aliases: OriginUrl, CloneUrl

Required: True
Position: 1
Default value: None
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

[https://github.com/OSDeploy/OSD.Workspace/blob/main/docs/Import-OSDWorkspaceGitHubRepo.md](https://github.com/OSDeploy/OSD.Workspace/blob/main/docs/Import-OSDWorkspaceGitHubRepo.md)

