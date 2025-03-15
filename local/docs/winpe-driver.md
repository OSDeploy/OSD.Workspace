# BootDriver

This folder contains WinPE Drivers that are consumed by `New-OSDWorkspaceBootMedia`

Files are stored in the following directory structre:

```plaintext
C:\OSDWorkspace\BootDriver\<Architecture>\<DriverName>\<Drivers>
```

## Architecture
Architecture is the CPU architecture of the target machine. The following structure is required and automatically created.

```plaintext
C:\OSDWorkspace\BootDriver\amd64
C:\OSDWorkspace\BootDriver\arm64
```

## DriverName
DriverName is the name of the driver. This can be any name that you want to use to identify the driver. The DriverName folder contains the driver files that are required for the driver to be installed. Since these can be combined, the following structure is recommended

```plaintext
C:\OSDWorkspace\BootDriver\amd64\Dell
C:\OSDWorkspace\BootDriver\amd64\HP
C:\OSDWorkspace\BootDriver\amd64\Lenovo
C:\OSDWorkspace\BootDriver\amd64\Surface-Laptop5

C:\OSDWorkspace\BootDriver\arm64\Surface-Laptop7
```

## Drivers
Drivers should be downloaded from the appropriate manufacturer and placed in the appropriate folder, expanded. Subfolders are allowed as Drivers are applied recursively.

## WinPE Driver Sources
- HP
  - Links: https://ftp.ext.hp.com/pub/caps-softpaq/cmit/HP_WinPE_DriverPack.html
- Dell
  - Links: https://www.dell.com/support/kbdoc/en-us/000107478/dell-command-deploy-winpe-driver-packs
- Lenovo
  - Links: https://support.lenovo.com/us/en/solutions/ht074984-microsoft-system-center-configuration-manager-sccm-and-microsoft-deployment-toolkit-mdt-package-index
- Surface
  - Links: https://learn.microsoft.com/en-us/surface/enable-surface-keyboard-for-windows-pe-deployment
  - Instructions: https://learn.microsoft.com/en-us/surface/enable-surface-keyboard-for-windows-pe-deployment

## Git Ignore
This folder can be saved in an Git Repository, keeping in mind that file sizes larger than 100MB are not cached.
It is recommended that you exclude the Driver directories by adding this entry to your Workspace .gitignore file

```.gitignore
BootDriver/amd64/*/*
BootDriver/arm64/*/*
```