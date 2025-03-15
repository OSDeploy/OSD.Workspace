# WinPE

## Description
The OSDWorkspace WinPE folder is located at C:\OSDWorkspace\WinPE. This folder is used to store WinPE BootMedia which can be used to create a bootable USB from the `WinPE-Media` and `WinPE-MediaEX` folders. The `ISO` folder contains ISO files which can be used to boot Virtual Machines, or to burn to a CD/DVD.

## Default State
The default state of the WinPE folder is empty, only containing this `README.md`. This folder is automatically created when any of the `OSD.Workspace PowerShell Module` functions are used for the first time.

## Adding Content
Content is added to the WinPE folder by using the `Build-OSDWorkspaceWinPE` function from the `OSD.Workspace PowerShell Module`.

```powershell
#Requires -RunAsAdministrator
Build-OSDWorkspaceWinPE -Name 'OSDCloud'
```

## Editing Content
Content in the WinPE folder should not be edited directly, other than renaming subfolders for organizational purposes.

## Removing Content
Content can be removed from the WinPE folder by deleting any of the subfolders.

## Subfolders
WinPE subfolders are created automatically by adding content using the `Build-OSDWorkspaceWinPE` function from the `OSD.Workspace PowerShell Module`. The subfolders are named using a default naming convention.

Each subfolder (like `250308-1649-amd64`) represents a specific WinPE build with the naming format of `{date}-{time}-{architecture}`.

Where:
- `{date}` is the date the WinPE was created in the format `yyMMdd`
- `{time}` is the time the WinPE was created in the format `HHmm`
- `{architecture}` is the architecture of the BootMedia, either `amd64` or `arm64`

This folder can be renamed for organizational purposes.

## Index.json
The WinPE folder contain an `index.json` file that contains the details of all the WinPE builds in each subfolder. The `index.json` file is automatically created and updated by functions in the `OSD.Workspace PowerShell Module`.


## Creating WinPE
OSDWorkspace does not include any WinPE content by default, they are created using an imported Windows 11 Operating System and the optional components from the Windows Assessment and Deployment Kit (Windows ADK). `Build-OSDWorkspaceWinPE` is used to start the build process. Once created, the BootMedia will be saved in a WinPE subfolder.

### Requirements
- Administrator Privileges
- Windows Assessment and Deployment Kit (Windows ADK)
- Imported Operating System and Windows Recovery Environment
- Basic PowerShell Knowledge

### Create a new WinPE in VS Code Terminal (User Mode)
1. Run the following command in VS Code Terminal, replacing `MyName` with the desired name of the WinPE Build:

```powershell
# PowerShell 7. For PowerShell 5.1 replace pwsh with powershell
Start-Process pwsh -Verb RunAs -ArgumentList '-NoExit',"-Command Build-OSDWorkspaceWinPE -Name 'MyName'"
```

2. Select an imported `WinRE` when prompted in the PowerShell Out-GridView window and press OK (Cancel to exit)
3. Select any Library `WinPE-Drivers`, `WinPE-Scripts`, or `WinPE-MediaScripts` to configure the WinPE
4. The BootMedia will be saved in an OSDWorkspace Media subfolder using the default naming convention

### Create a new WinPE using PowerShell (external)
1. Open Windows Terminal with Administrator rights:
    - Press Win + X and select Windows Terminal (Admin) from the menu.
    - Confirm the User Account Control (UAC) prompt.
2. In the elevated Windows Terminal, run the following command in Windows Terminal, replacing `MyName` with the desired name of the WinPE Build:

```powershell
#Requires -RunAsAdmin
Build-OSDWorkspaceWinPE -Name 'MyName'
```

2. Select an imported `WinRE` when prompted in the PowerShell Out-GridView window and press OK (Cancel to exit)
3. Select any Library `WinPE-Drivers`, `WinPE-Scripts`, or `WinPE-MediaScripts` to configure the WinPE
4. The BootMedia will be saved in an OSDWorkspace Media subfolder using the default naming convention