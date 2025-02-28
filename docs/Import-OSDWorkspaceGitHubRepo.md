---
external help file: OSD.Workspace-help.xml
Module Name: OSD.Workspace
online version:
schema: 2.0.0
---

# Import-OSDWorkspaceGitHubRepo

## SYNOPSIS
Clones a GitHub Repository into C:\OSDWorkspace\Library-GitHub

## SYNTAX

```
Import-OSDWorkspaceGitHubRepo [-Url] <Uri> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Clones a GitHub Repository into C:\OSDWorkspace\Library-GitHub

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Url
GitHub Origin HTTPS URL in the format https://github.com/RepositoryOwner/RepositoryName.git

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

## NOTES
David Segura

## RELATED LINKS
