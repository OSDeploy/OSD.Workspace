# Requirements

### Windows 11 amd64 24H2
OSDWorkspace was developed for use on Windows 11 amd64 24H2. Other operating systems are untested and unsupported, including Insiders versions, arm64, and Server operating systems.


### PowerShell 7.5
https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.5

OSDWorkspace was developed for use with PowerShell 7.5. Other versions of PowerShell are untested and unsupported.

```powershell
# Install PowerShell 7.5
winget install -e --id Microsoft.PowerShell --scope user --override '/Passive ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ADD_FILE_CONTEXT_MENU_RUNPOWERSHELL=1 ADD_PATH=1'
```

Additionally since most DISM functions require Admin Rights to run properly, so you will need to run PowerShell as an Administrator.


### Git for Windows
https://gitforwindows.org/

Git for Windows is also required for OSDWorkspace to function properly. If Git for Windows is not installed, all OSDWorkspace functions will result in an error.

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