# OSD.Workspace PowerShell Module
https://github.com/OSDeploy/OSD.Workspace

## Disclaimer
This software is provided "as-is," without any express or implied warranty. In no event shall the authors be held liable for any damages arising from the use of this software.

---

## Requirements

### Windows 11 amd64 24H2
OSD.Workspace was developed for use on Windows 11 amd64 24H2. Other operating systems are untested and unsupported, including Insiders versions, arm64, and Server operating systems.


### PowerShell 7.5
https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.5

OSD.Workspace was developed for use with PowerShell 7.5. Other versions of PowerShell are untested and unsupported.

```powershell
# Install PowerShell 7.5
winget install -e --id Microsoft.PowerShell --scope user --override '/Passive ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ADD_FILE_CONTEXT_MENU_RUNPOWERSHELL=1 ADD_PATH=1'
```

Additionally since most DISM functions require Admin Rights to run properly, you will need to run PowerShell as an Administrator for most OSD.Workspace functions.


### Git for Windows
https://gitforwindows.org/

Git for Windows is also required for OSD.Workspace to function properly. If Git for Windows is not installed, all OSD.Workspace functions may result in an error, or not function.

```powershell
# Install Git for Windows
winget install -e --id Git.Git
```

### Visual Studio Code
https://code.visualstudio.com/docs/setup/windows

This module was developed for use with Visual Studio Code as a Workspace.

```powershell
# Install Visual Studio Code
winget install -e --id Microsoft.VisualStudioCode --override '/SILENT /mergetasks="!runcode,addcontextmenufiles,addcontextmenufolders"'
```

### Microsoft Windows ADK
https://learn.microsoft.com/en-us/windows-hardware/get-started/adk-install

Microsoft Windows ADK is used for the Windows PE creation process and the optional components are required.


## OSD.Workspace PowerShell Module Installation

Install the OSD.Workspace PowerShell Module from the PowerShell Gallery.

```powershell
Install-Module -Name OSD.Workspace -Scope CurrentUser -SkipPublisherCheck
```

## OSD.Workspace First Run
After installing the OSD.Workspace PowerShell Module, you should relaunch PowerShell to load the module into your session. Then run the following command

```powershell
Get-OSDWorkspace
```
---