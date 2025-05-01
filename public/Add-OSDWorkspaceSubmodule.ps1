function Add-OSDWorkspaceSubmodule {
    <#
    .SYNOPSIS
        Adds a GitHub repository as a submodule to the OSDWorkspace\submodules directory.

    .DESCRIPTION
        The Add-OSDWorkspaceSubmodule function adds a GitHub repository as a submodule to the OSDWorkspace submodules directory 
        (typically located at C:\OSDWorkspace\submodules).
        
        This function performs the following operations:
        1. Validates administrator privileges
        2. Checks if the URL is a valid GitHub repository with .git extension
        3. Creates the submodules directory if it doesn't exist
        4. Executes 'git submodule add' operation to add the repository
        5. Commits the changes to the OSDWorkspace parent repository
        
        The submodule is added with the repository name extracted from the URL. The destination path will be
        submodules/[RepositoryName] within the OSDWorkspace root directory.
        
        If you need to update an existing submodule, use the Update-OSDWorkspaceSubmodule function instead.

    .PARAMETER Url
        The HTTPS URL of the GitHub repository to add as a submodule.
        Must be in the format https://github.com/RepositoryOwner/RepositoryName.git
        
        This parameter is mandatory and is validated to ensure it follows the correct GitHub URL pattern.
        This parameter also supports the aliases 'OriginUrl' and 'CloneUrl'.

    .EXAMPLE
        Add-OSDWorkspaceSubmodule -Url 'https://github.com/OSDeploy/osdws-gallery.git'
        
        Adds the OSDWorkspace Gallery as a submodule to the OSDWorkspace submodules directory.

    .EXAMPLE
        Add-OSDWorkspaceSubmodule -Url 'https://github.com/OSDeploy/OSDCloud.git' -Verbose
        
        Adds the OSDCloud repository as a submodule with verbose output showing each step of the process.

    .OUTPUTS
        None. This function does not generate any output objects.

    .NOTES
        Author: David Segura
        Version: 1.0
        Date: April 2025
        
        Prerequisites:
            - Git for Windows must be installed and available in the system's PATH. (https://gitforwindows.org/)
            - PowerShell 7.5 or higher is recommended.
            - The script must be run with administrator privileges.
            - The target OSDWorkspace repository (typically C:\OSDWorkspace) must be initialized as a Git repository.
        
        This function modifies the parent Git repository by adding a submodule and creating a commit.
        After adding the submodule, you may need to initialize and update it using:
        git submodule update --init --recursive
        
        For more information about Git submodules, see:
            https://git-scm.com/docs/git-submodule
            https://git-scm.com/book/en/v2/Git-Tools-Submodules
    #>


    [CmdletBinding()]
    param (
        # GitHub Origin HTTPS URL in the format https://github.com/RepositoryOwner/RepositoryName.git
        [Parameter(Mandatory = $true)]
        [ValidatePattern('^https:\/\/github\.com\/[\w\-]+\/[\w\-]+\.git$')]
        [Alias('OriginUrl', 'CloneUrl')]
        [System.Uri]
        $Url
    )
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
    # Url must have a .git extension
    if ($Url -notlike '*.git') {
        Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Url must have a .git extension"
        return
    }
    #=================================================
    # Url must be a GitHub hosted repository
    if ($Url.Authority -ne 'github.com') {
        Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Url must be a GitHub hosted repository"
        return
    }
    #=================================================
    # Get Paths
    $OSDWorkspaceRoot = $OSDWorkspace.path
    $LibrarySubmodulePath = $OSDWorkspace.paths.library_submodule
    #=================================================
    # Create submodules
    if (-not (Test-Path $LibrarySubmodulePath -ErrorAction SilentlyContinue)) {
        New-Item -Path $LibrarySubmodulePath -ItemType Directory -Force | Out-Null
    }
    #=================================================
    # Region Build the paths
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] LibrarySubmodulePath: $LibrarySubmodulePath"

    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Repository Url to Add: $Url"
    
    $RepositoryName = (Split-Path $Url -Leaf).Replace('.git', '')
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Repository Name to Add: $RepositoryName"

    $Destination = "submodules/$RepositoryName"
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Repository Destination: $Destination"

    <#
    if (Test-Path -Path "$Destination\.git") {
        Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Destination repository already exists"
        Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Use the Update-OSDWorkspaceSubmodule cmdlet to update this repository"
        return
    }
    #>
    #endregion
    #=================================================
    # Region Git Submodule Add
    # https://git-scm.com/docs/git-submodule
    # https://git-scm.com/book/en/v2/Git-Tools-Submodules
    # git submodule add <URL> <path>

    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Push-Location $OSDWorkspaceRoot"
    Push-Location $OSDWorkspaceRoot

    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] git submodule add $Url submodules/$RepositoryName"
    git submodule add $Url submodules/$RepositoryName

    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] git commit -m `"Add submodule $RepositoryName`""
    git commit -m "Add submodule $RepositoryName"

    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Pop-Location"
    Pop-Location
    #endregion
    #=================================================
    # Region Git Clone
    <#
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] git clone --verbose --progress --single-branch --depth 1 `"$Source`" `"$Destination`""
    git clone --verbose --progress --single-branch --depth 1 "$Source" "$Destination"

    if (Test-Path "$Destination\.git") {
        Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Push-Location `"$Destination`""
        Push-Location "$Destination"

        Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] git fetch --verbose --progress --depth 1 origin"
        git fetch --verbose --progress --depth 1 origin

        # Can leave this out since this is the first clone
        # Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] git reset --hard origin"
        # git reset --hard origin

        Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] git clean -d --force"
        git clean -d --force

        Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Pop-Location"
        Pop-Location
    }
    else {
        Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Failed to clone repository"
    }
    #>
    #endregion
    #=================================================
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}