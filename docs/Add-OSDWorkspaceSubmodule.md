---
external help file: OSD.Workspace-help.xml
Module Name: OSD.Workspace
online version:
schema: 2.0.0
---

# Add-OSDWorkspaceSubmodule

## SYNOPSIS
Adds a GitHub repository as a submodule to the OSDWorkspace\submodules directory.

## SYNTAX

```
Add-OSDWorkspaceSubmodule [-Url] <Uri> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
The Add-OSDWorkspaceSubmodule function adds a GitHub repository as a submodule to the OSDWorkspace submodules directory 
(typically located at C:\OSDWorkspace\submodules).

This function performs the following operations:
1.
Validates administrator privileges
2.
Checks if the URL is a valid GitHub repository with .git extension
3.
Creates the submodules directory if it doesn't exist
4.
Executes 'git submodule add' operation to add the repository
5.
Commits the changes to the OSDWorkspace parent repository

The submodule is added with the repository name extracted from the URL.
The destination path will be
submodules/\[RepositoryName\] within the OSDWorkspace root directory.

If you need to update an existing submodule, use the Update-OSDWorkspaceSubmodule function instead.

## EXAMPLES

### EXAMPLE 1
```
Add-OSDWorkspaceSubmodule -Url 'https://github.com/OSDeploy/osdws-gallery.git'
```

Adds the OSDWorkspace Gallery as a submodule to the OSDWorkspace submodules directory.

### EXAMPLE 2
```
Add-OSDWorkspaceSubmodule -Url 'https://github.com/OSDeploy/OSDCloud.git' -Verbose
```

Adds the OSDCloud repository as a submodule with verbose output showing each step of the process.

## PARAMETERS

### -Url
The HTTPS URL of the GitHub repository to add as a submodule.
Must be in the format https://github.com/RepositoryOwner/RepositoryName.git

This parameter is mandatory and is validated to ensure it follows the correct GitHub URL pattern.
This parameter also supports the aliases 'OriginUrl' and 'CloneUrl'.

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
    - The target OSDWorkspace repository (typically C:\OSDWorkspace) must be initialized as a Git repository.

This function modifies the parent Git repository by adding a submodule and creating a commit.
After adding the submodule, you may need to initialize and update it using:
git submodule update --init --recursive

For more information about Git submodules, see:
    https://git-scm.com/docs/git-submodule
    https://git-scm.com/book/en/v2/Git-Tools-Submodules

## RELATED LINKS
