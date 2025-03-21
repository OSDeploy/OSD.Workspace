# What is OSDWorkspace
OSDWorkspace is a VS Code Workspace 
OSDWorkspace is located at C:\OSDWorkspace
OSDWorkspace is used to build WinPE BootImages and BootMedia.
OSDWorkspace should only be opened in Visual Studio Code
OSDWorkspace only runs on Windows 11.
OSDWorkspace does not work on Windows Server or Windows 10 is not supported.

# What is OSD.Workspace PowerShell Module
OSDWorkspace is managed by PowerShell functions in the OSD.Workspace PowerShell Module.
OSD.Workspace functions are documented in C:\OSDWorkspace\docs\powershell-help\OSD.Workspace\*.md files.
OSD.Workspace functions need to be Run as Administrator.
OSD.Workspace functions should be run in Windows Terminal.

# OSDWorkspace Folder Structure
OSDWorkspace has the below folder structure:
- Build
- Cache
- Library
- src
- Submodules

# build Folder
The [Build](/build/) folder is named 'Build'
The [Build](/build/) folder is located at C:\OSDWorkspace\Build
The [Build](/build/) folder contains WinPE BootMedia created by the OSD.Workspace PowerShell Module.
The [Build](/build/) folder contains BootImages created by the OSD.Workspace PowerShell Module.
The [Build](/build/) folder contains a subfolder [windows-pe](/build/windows-pe/)
The [windows-pe](/build/windows-pe/) folder is named 'windows-pe'
The [windows-pe](/build/windows-pe/) is located at C:\OSDWorkspace\Build\windows-pe
The [windows-pe](/build/windows-pe/) folder contains the BootMedia created by the OSD.Workspace PowerShell Module.
The [windows-pe](/build/windows-pe/) folder contains subfolders for each BootMedia.
The subfolders have the named format '<Date>-<Time>-<Architecture>'.

# cache Folder
The [Cache](/cache/) folder is named 'Cache'
The [Cache](/cache/) folder is located at C:\OSDWorkspace\Cache
The [Cache](/cache/) is managed automatically by the OSDWorkspace.
The [Cache](/cache/) folder contains offline files that are used to build BootMedia.
The [Cache](/cache/) folder contains:
* [adk-versions](/cache/adk-versions/)
    * Stores offline versions of the Windows ADK.
* [powershell-modules](/cache/powershell-modules/)
    * Contains offline copies of required PowerShell modules.
* [addon-packages](/cache/addon-packages/)
    * Contains offline copies of required Addon packages
        * 7-Zip
        * AzCopy
        * MicrosoftDaRT
        * WirelessConnect
* [winpe-buildprofiles](/cache/winpe-buildprofile/)
    * BuildProfiles are saved configurations for building BootMedia.

# library Folder
The [Library](/library/) folder is named 'Library'
The [Library](/library/) folder is located at C:\OSDWorkspace\Library
The [Library](/library/) is where you store content that is used by OSDWorkspace to create BootMedia.
The [Library](/library/) folder contains subfolders of profiles.
Each subfolder contains Drivers and Scripts used to create BootMedia.
Each subfolder should have 3 folders named:
* winpe-driver
* winpe-mediascript
* winpe-script

# src Folder
The [Source](/src/) folder is named 'src'
The [Source](/src/) folder is located at C:\OSDWorkspace\src
The [Source](/src/) folder contains a subfolder [windows-re](/src/windows-re/)
The [windows-re](/src/windows-re/) folder contains imported Windows Recovery Environment (WinRE) images.
Avaialble Windows RE images are only stored in the [index.json](/build/windows-re/index.json) file.
The [Source](/src/) folder contains a subfolder [windows-os](/src/windows-os/)
The [windows-os](/src/windows-os/) folder contains imported Windows OS Media.
Available Windows OS Media are only stored in the [index.json](/build/windows-os/index.json) file.

# submodules Folder
The [Submodules](/submodules/) folder is named 'Submodules'
The [Submodules](/submodules/) folder is located at C:\OSDWorkspace\Submodules
The [Submodules](/submodules/) folder contains added Submodules to the OSDWorkspace.
Submodules are defined in the [.gitmodules](/.gitmodules) file.
Submodules are Git repositories that are added to the main Git Initialized OSDWorkspace.
Submodules should only contain subfolders named:
* winpe-driver
* winpe-mediascript
* winpe-script

# BootMedia
BootMedia is also referred to as 'Boot Media'.
Avaialble BootMedia is only stored in the [index.json](/build/windows-pe/index.json) file.
Default attributes to show from the [index.json](/build/windows-pe/index.json) file are:
- Id
- Name
- Architecture
- Version
- Languages
- Path
- OSVersion

AddOn attributes are set to true if they are included in the BootMedia.
AddOn attributes are set to false if they are not included in the BootMedia.
Show AddOn attributes that true.
AddOn attributes in the [index.json](/build/windows-pe/index.json) file are:
- AddOnAzCopy
- AddOnMicrosoftDaRT
- AddOnOpenSSH
- AddOnPwsh
- AddOnWirelessConnect
- AddOnZip

# BootImage
BootImages are also referred to as 'Boot Images'.
BootImages are imported from a mounted Windows Installation Iso.
BootImages are used to create BootMedia.

# Indentation
We use tabs, not spaces.