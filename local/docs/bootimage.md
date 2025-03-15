# BootImage


## Description
The OSDWorkspace BootImage folder is located at C:\OSDWorkspace\BootImage. This folder is used to store BootImages that are imported from a mounted Windows Installation Iso. The BootImages are used to create BootMedia.


### Default State
The default state of BootImage folder is empty, only containing this README.md. This folder is automatically created when any of the `OSD.Workspace PowerShell Module` functions are used for the first time.


### Adding Content
Content is added to the BootImage folder by importing a Windows Recovery Image from a mounted Windows Installation Iso using the `Import-OSDWorkspaceWinOS` function from the `OSD.Workspace PowerShell Module`.

```powershell
#Requires -RunAsAdministrator
Import-OSDWorkspaceWinOS
```

### Editing Content
Content in the BootImage folder should not be edited directly, other than renaming Subfolders for organizational purposes.


### Removing Content
Content can be removed from the BootImage folder by deleting any of the subfolders within BootImage.


### Subfolders
BootImage subfolders are created automatically by adding content using the `Import-OSDWorkspaceWinOS` function from the `OSD.Workspace PowerShell Module`. The subfolders are named using a default naming convention. The default naming convention is unique and includes the date and time the BootImage was imported and the architecture of the BootImage in the following format:

```text
C:\OSDWorkspace\BootImage\<DateTime> <Architecture>
```

Where:
- `<DateTime>` is the date and time the BootImage was imported in the format `yyMMdd-HHmmss`
- `<Architecture>` is the architecture of the BootImage, either `amd64` or `arm64`

Subfolders can be renamed for organizational purposes, although this is not recommended if you have `BootMedia Profiles` that directly reference the BootImage subfolder by name.


### Index.json
The BootImage folder contain an `index.json` file that contains the details of all the BootImage subfolders. The `index.json` file is automatically created and updated by OSDWorkspace.


## Importing a BootImage
OSDWorkspace does not include any BootImages by default, they are imported from a mounted Windows Installation Iso. The `Import-OSDWorkspaceWinOS` function will import the selected Windows Recovery Environment image. The BootImage will be saved in the BootImage subfolder. Once imported, the BootImage can be used to create BootMedia for OSDWorkspace.

### Requirements
- Administrator Privileges
- Windows Installation Iso Media
- Basic PowerShell Knowledge

### Import a BootImage in VS Code Terminal (User Mode)
1. Mount a supported Windows Installation Client ISO file
2. Run the following command in VS Code Terminal:

```powershell
# PowerShell 7. For PowerShell 5.1 replace pwsh with powershell
Start-Process pwsh -Verb RunAs -ArgumentList '-NoExit','-Command Import-OSDWorkspaceWinOS'
```

3. Drives will be scanned for a Windows Installation
4. Media will be presented in PowerShell Out-GridView allowing you to select an OS WindowsImage and pressing OK (Cancel to exit)
5. The OS WindowsImage will be exported to `$env:Temp` and mounted to extract the winre.wim and additional files
6. The BootImage will be saved in an OSDWorkspace BootImage subfolder using the default naming convention

### Import a BootImage using PowerShell (external)
1. Mount a supported Windows Installation Client ISO file
2. Open Windows Terminal with Administrator rights:
    - Press Win + X and select Windows Terminal (Admin) from the menu.
    - Confirm the User Account Control (UAC) prompt.
3. In the elevated Windows Terminal, run the following command in Windows Terminal:

```powershell
#Requires -RunAsAdmin
Import-OSDWorkspaceWinOS
```

4. Drives will be scanned for a Windows Installation
5. Found WindowsImages will be presented in PowerShell Out-GridView allowing you to select an OS WindowsImage and pressing OK (Cancel to exit)
6. The OS WindowsImage will be exported to `$env:Temp` and mounted to extract the winre.wim and additional files
7. The BootImage will be saved in an OSDWorkspace BootImage subfolder using the default naming convention 