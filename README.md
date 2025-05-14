# OSD.Workspace PowerShell Module
https://github.com/OSDeploy/OSD.Workspace

## Disclaimer
This software is provided "as-is," without any express or implied warranty. In no event shall the authors be held liable for any damages arising from the use of this software.

---

## Requirements

- Hardware:
  - 64-bit CPU
  - 4 CPU Cores (8 Cores recommended)
  - 24GB RAM (32GB recommended)
  - 50GB free disk space (NVMe recommended)
- OS: Windows 11 amd64 24H2
- PowerShell 7.5+
- Git for Windows
- Visual Studio Code
- Visual Studio Code Insiders (optional)
- Microsoft Windows ADK
- PowerShell Modules:
  - platyPS
  - OSD
- PowerShell Modules (optional):
  - OSDCloud


## Detailed Requirements

You should be able to handle the installation of all the requirements above. If this is too challenging, OSD.Workspace may be a little to advanced for you at this time. OSD.Workspace is designed to be a tool for advanced users and developers. This section will provide some additional details on the requirements that should work in most cases. If any of these instructions don't work for you, please submit a PR with your solution.

### Windows 11 amd64 24H2

OSD.Workspace was developed for use on Windows 11 amd64 24H2. Other operating systems are untested and unsupported, including Windows 10, Windows 11 Insiders versions, arm64, and Server operating systems. You can submit an Issue if you encounter any problems with these operating systems, but please note that they are not supported, and you may not receive a response.

### Get PowerShell 5.1 up to date

```powershell
#Requires -RunAsAdministrator
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force

if ($(Get-PackageProvider).Name -notcontains "NuGet") {
    Install-PackageProvider -Name NuGet -Force
}

$InstalledModule = Get-Module -Name PackageManagement -ListAvailable | Where-Object { $_.Version -ge '1.4.8.1' }
if (-not ($InstalledModule)) {
    Install-Module -Name PackageManagement -Force -Scope AllUsers -AllowClobber -SkipPublisherCheck
}

$InstalledModule = Get-Module -Name PowerShellGet -ListAvailable | Where-Object { $_.Version -ge '2.2.5'}
if (-not ($InstalledModule)) {
    Install-Module -Name PowerShellGet -Force -Scope AllUsers -AllowClobber -SkipPublisherCheck
}

# Close PowerShell or Windows Terminal to make sure everything is working fine
```

### PowerShell 7.5

[PowerShell Installation Guide](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.5)

OSD.Workspace was developed for use with PowerShell 7.5. Other versions of PowerShell are untested and unsupported. Since PowerShell 7.5 is required, the OSD.Workspace module will not even load on PowerShell 5.1.

```powershell
# Install PowerShell 7.5
winget install -e --id Microsoft.PowerShell --override '/Passive ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ADD_FILE_CONTEXT_MENU_RUNPOWERSHELL=1 ADD_PATH=1'
```

Additionally since most DISM functions require Admin Rights to run properly, you will need to run PowerShell as an Administrator for most OSD.Workspace functions.

### Install OSD.Workspace PowerShell Module

In PowerShell 7.5, install the OSD.Workspace PowerShell Module from the PowerShell Gallery.

```powershell
Install-Module -Name OSD.Workspace -SkipPublisherCheck
``` 

Once the module is installed, you can import it into your session using the following command.

```powershell
Import-Module OSD.Workspace
```

Additionally, you can use the following OSD.Workspace function to complete the setup of OSDWorkspace, although you will need to sort out the installation of the Windows ADK.

```powershell
Install-OSDWorkspace
```

### Git for Windows

[Git for Windows](https://gitforwindows.org/)

Git for Windows is required for OSD.Workspace to function properly. If Git for Windows is not installed, all OSD.Workspace functions may result in an error, or not function. You can install Git for Windows using the following command. If you have a different version of Git installed, you may need to uninstall it first.

```powershell
winget install -e --id Git.Git
```

### Visual Studio Code

[Visual Studio Code Setup](https://code.visualstudio.com/docs/setup/windows)

This module was developed for use with Visual Studio Code as a Workspace. We like to use Insiders.

```powershell
# Visual Studio Code
winget install -e --id Microsoft.VisualStudioCode
```

```powershell
# Visual Studio Code (with recommended options)
winget install -e --id Microsoft.VisualStudioCode --override '/SILENT /mergetasks="!runcode,addcontextmenufiles,addcontextmenufolders,associatewithfiles,addtopath"'
```

```powershell
# Visual Studio Code Insiders
winget install -e --id Microsoft.VisualStudioCode.Insiders
```

```powershell
# Visual Studio Code Insiders (with recommended options)
winget install -e --id Microsoft.VisualStudioCode.Insiders --override '/SILENT /mergetasks="!runcode,addcontextmenufiles,addcontextmenufolders,associatewithfiles,addtopath"'
```

### PowerShell Modules

In PowerShell 7.5, install the following modules from the PowerShell Gallery.

```powershell
Install-Module -Name platyPS -SkipPublisherCheck
Install-Module -Name OSD -SkipPublisherCheck
Install-Module -Name OSDCloud -SkipPublisherCheck
```

### Microsoft Windows ADK

[Microsoft Windows ADK Installation Guide](https://learn.microsoft.com/en-us/windows-hardware/get-started/adk-install)

**Note**

Winget install doesn't work when I last tested this so you'll have to use the link above to download the ADK installer.

Microsoft Windows ADK is used for the Windows PE creation process and the optional components are required. These instructions are for the 24H2 version of the ADK. If you are using a different version, you may need to adjust the instructions accordingly.

```powershell
winget install --id Microsoft.WindowsADK -e -v 10.1.26100.2454 --accept-source-agreements --accept-package-agreements --wait --override '/features OptionId.DeploymentTools OptionId.Documentation OptionId.ImagingAndConfigurationDesigner /quiet /ceip off /norestart'
```

### Microsoft Windows ADK WinPE Addon

For some reason Microsoft does not show this in winget anymore, so this will have to do.

```powershell
$Url = 'https://go.microsoft.com/fwlink/?linkid=2289981'
Invoke-Expression "& curl.exe --insecure --location --output `"$env:TEMP\adkwinpesetup.exe`" --url `"$Url`""
Start-Process -FilePath "$env:TEMP\adkwinpesetup.exe" -ArgumentList '/features', 'OptionId.WindowsPreinstallationEnvironment', '/quiet', '/ceip', 'off', '/norestart' -Wait
```

## OSD.Workspace First Run

After installing the OSD.Workspace PowerShell Module, you should relaunch PowerShell to load the module into your session. Then run the following command

```powershell
Get-OSDWorkspace
```

---
