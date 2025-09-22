function Remove-OSDWorkspaceWinPEBuild {
    <#
    .SYNOPSIS
        Removes one or more WinPE builds from the OSDWorkspace environment.

    .DESCRIPTION
        The Remove-OSDWorkspaceWinPEBuild function removes selected WinPE builds from the OSDWorkspace build directory 
        (typically located at C:\OSDWorkspace\build\windows-pe) and associated build profile files from the cache.
        
        This function performs the following operations:
        1. Validates administrator privileges
        2. Displays available WinPE builds in a grid view for selection (supports multiple selection)
        3. For each selected build:
           a. Removes the build directory and all its contents
           b. Removes any associated build profile files from the cache
        4. Updates the WinPE build index to reflect the changes
        
        The -Force parameter is required to perform the deletion operation as a safety measure.

    .PARAMETER Architecture
        Optional parameter to filter builds by architecture (amd64, arm64).
        If not specified, builds from all architectures will be displayed for selection.

    .PARAMETER Force
        Required switch parameter to confirm that you want to delete the selected builds.
        This is a safety measure to prevent accidental deletion of WinPE builds.

    .EXAMPLE
        Remove-OSDWorkspaceWinPEBuild -Force
        
        Displays all available WinPE builds for selection and removes the selected builds from the OSDWorkspace.

    .EXAMPLE
        Remove-OSDWorkspaceWinPEBuild -Architecture 'amd64' -Force
        
        Displays only amd64 WinPE builds for selection and removes the selected builds.

    .EXAMPLE
        Remove-OSDWorkspaceWinPEBuild -Force -Verbose
        
        Removes selected WinPE builds with detailed output showing each step of the process.

    .OUTPUTS
        None. This function does not generate any output objects.

    .NOTES
        Author: Matthew Miles
        Version: 1.0
        Date: September 22, 2025
        
        Prerequisites:
            - PowerShell 5.0 or higher
            - Windows 10 or higher
            - The script must be run with administrator privileges.
            - WinPE builds must exist in the OSDWorkspace build directory.
        
        This function permanently removes selected WinPE builds from the OSDWorkspace environment.
        This is a destructive operation that cannot be undone except by restoring from a backup.
        
        The function will also remove associated build profile files (.json) from the cache directory
        if they match the name of the removed builds.
    #>

    
    [CmdletBinding()]
    param (
        # Specifies the processor architecture to filter builds by.
        # Valid values are 'amd64' (64-bit x86) and 'arm64' (64-bit ARM).
        [ValidateSet('amd64', 'arm64')]
        [System.String]
        $Architecture,

        # Force the deletion of the WinPE builds from OSDWorkspace
        [Parameter(Mandatory)]
        [System.Management.Automation.SwitchParameter]
        $Force
    )

    begin {
        #=================================================
        $Error.Clear()
        Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Start"
        Initialize-OSDWorkspace
        #=================================================
        # Requires Run as Administrator
        $IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        if (-not $IsAdmin ) {
            Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] This function must be Run as Administrator"
            return
        }
        #=================================================
        # Import OSD.Workspace settings
        if (-not $global:OSDWorkspace) {
            Import-OSDWorkspaceSettings
        }
        #=================================================
    }

    process {
        #=================================================
        #region Get Available WinPE Builds
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Getting available WinPE builds"
        
        if ($Architecture) {
            $AvailableBuilds = Get-OSDWSWinPEBuild -Architecture $Architecture
        }
        else {
            $AvailableBuilds = Get-OSDWSWinPEBuild
        }

        if (-not $AvailableBuilds) {
            Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] No WinPE builds found"
            if ($Architecture) {
                Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] No WinPE builds found for architecture '$Architecture'"
            }
            return
        }
        #endregion
        #=================================================
        #region Select Builds to Remove
        Write-Host -ForegroundColor DarkCyan "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Select WinPE builds to remove (Cancel to exit)"
        $SelectedBuilds = $AvailableBuilds | Select-Object Name, Id, Architecture, Version, DisplayVersion, ModifiedTime, Path | 
            Out-GridView -Title 'Select WinPE builds to remove and press OK (Cancel to exit)' -OutputMode Multiple

        if (-not $SelectedBuilds) {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] No builds selected for removal"
            return
        }

        Write-Host -ForegroundColor Yellow "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Selected $($SelectedBuilds.Count) build(s) for removal:"
        foreach ($Build in $SelectedBuilds) {
            Write-Host -ForegroundColor Yellow "  - $($Build.Name) ($($Build.Architecture)) - $($Build.Path)"
        }
        #endregion
        #=================================================
        #region Process Removal
        if ($Force -eq $true) {
            foreach ($Build in $SelectedBuilds) {
                Write-Host -ForegroundColor DarkCyan "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Processing build: $($Build.Name)"
                Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Build Path: $($Build.Path)"

                #region Remove Build Directory
                if (Test-Path $Build.Path) {
                    Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Removing WinPE build directory: $($Build.Path)"
                    try {
                        Remove-Item -Path $Build.Path -Recurse -Force -ErrorAction Stop
                        Write-Host -ForegroundColor Green "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Successfully removed build directory: $($Build.Path)"
                    }
                    catch {
                        Write-Error "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Failed to remove build directory: $($Build.Path). Error: $($_.Exception.Message)"
                        continue
                    }
                }
                else {
                    Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Build directory not found: $($Build.Path)"
                }
                #endregion
                
                #region Remove Associated Build Profile
                $BuildProfilePath = $OSDWorkspace.paths.winpe_buildprofile
                $ProfileFile = Join-Path $BuildProfilePath "$($Build.Name).json"
                
                if (Test-Path $ProfileFile) {
                    Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Removing associated build profile: $ProfileFile"
                    try {
                        Remove-Item -Path $ProfileFile -Force -ErrorAction Stop
                        Write-Host -ForegroundColor Green "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Successfully removed build profile: $ProfileFile"
                    }
                    catch {
                        Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Failed to remove build profile: $ProfileFile. Error: $($_.Exception.Message)"
                    }
                }
                else {
                    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] No associated build profile found at: $ProfileFile"
                }
                #endregion
            }

            #region Update Build Index
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Updating WinPE build index"
            try {
                $null = Get-OSDWSWinPEBuild
                Write-Host -ForegroundColor Green "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] WinPE build index updated successfully"
            }
            catch {
                Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Failed to update build index. Error: $($_.Exception.Message)"
            }
            #endregion

            Write-Host -ForegroundColor Green "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Removal operation completed. $($SelectedBuilds.Count) build(s) processed."
        }
        else {
            Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] This command will permanently delete the selected WinPE builds from OSDWorkspace."
            Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Use the -Force switch when running this command."
            Write-Host
        }
        #endregion
        #=================================================
    }
    
    end {
        #=================================================
        Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] End"
        #=================================================
    }
}