# OSDWorkspace Directory Structure

The OSDWorkspace directory structure is designed to be simple and easy to navigate. The root directory is the OSDWorkspace directory, which contains the following subdirectories:

- BootImage
    - Contains the boot image files for Windows PE and Windows RE.
    - Automatically created by the `Import-OSDWorkspaceWinOS` function.
    - Editing content in this directory is not supported.
- BootMedia
    - Contains the boot media files for Windows PE and Windows RE.
    - Automatically created by the `New-OSDWorkspaceBootMedia` function.
    - Editing content in this directory is not supported.
- Cache
    - Contains the BootMedia cache files.
    - Created by the `New-OSDWorkspaceBootMedia` function.
    - Editing content in this directory is not supported.
- Library
    - Contains Drivers and Scripts that are used when creating BootMedia.
    - Ingested by the `New-OSDWorkspaceBootMedia` function.
    - Editing content in this directory is required.
- Library-GitHub
    - Contains Drivers and Scripts that are used when creating BootMedia.
    - Ingested by the `New-OSDWorkspaceBootMedia` function.
    - Editing content in this directory is not supported.
    - Content in this directory is imported from GitHub Repositories and is added using the `Import-OSDWorkspaceGitHubRepo` function.
    - Content in this directory is updated from GitHub Repositories using the `Update-OSDWorkspaceGitHubRepo` function.