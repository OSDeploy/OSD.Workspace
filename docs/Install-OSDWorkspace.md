---
external help file: OSD.Workspace-help.xml
Module Name: OSD.Workspace
online version:
schema: 2.0.0
---

# Install-OSDWorkspace

## SYNOPSIS
Initializes and configures the OSDWorkspace environment.

## SYNTAX

```
Install-OSDWorkspace [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
The Install-OSDWorkspace function performs a series of checks and setup steps to ensure the OSDWorkspace is correctly configured.
This includes verifying the operating system, required software (VS Code, Git), PowerShell modules (NuGet, PackageManagement, PowerShellGet, platyPS, OSD),
and setting up the OSDWorkspace directory structure, Git repository, and necessary configuration files.
It also creates registry entries for OSDWorkspace and updates the default library paths.
The function requires Administrator privileges for the initial setup if the OSDWorkspace directory does not exist.

## EXAMPLES

### EXAMPLE 1
```
Install-OSDWorkspace
```

Description:
Runs the OSDWorkspace installation and configuration process.
This command should be run in a PowerShell console.
If it's the first time running and the OSDWorkspace directory (e.g., C:\OSDWorkspace) doesn't exist,
it must be run with Administrator privileges.

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

## OUTPUTS

## NOTES
Author: David Segura
Requires Administrator privileges for the first run to create the OSDWorkspace directory.
Ensures that the operating system is Windows Client OS, build 26100 or higher.
Installs or updates necessary PowerShell modules like PackageManagement, PowerShellGet, platyPS, and OSD.
Verifies the installation of VS Code and Git.
Initializes the OSDWorkspace git repository if it doesn't exist.
Creates standard OSDWorkspace files like .gitattributes, .gitignore, .github/copilot-instructions.md, and OSD.code-workspace.

## RELATED LINKS
