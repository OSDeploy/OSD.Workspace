function Add-OSDWorkspaceSubmodule {
    <#
    .SYNOPSIS
        Adds a GitHub Repository as a Submodule to C:\OSDWorkspace\Library-GitHub

    .DESCRIPTION
        This function adds a GitHub repository as a submodule to the OSDWorkspace Library-GitHub directory.
        Performs a 'git submodule add' operation and commits the changes to the OSDWorkspace repository.
        If you have already added the repository as a submodule, use the Update-OSDWorkspaceSubmodule cmdlet to update it.

    .EXAMPLE
        Add-OSDWorkspaceSubmodule -Url 'https://github.com/OSDeploy/osdsubmod-osdcloud-v1.git'
        Adds the repository 'osdsubmod-osdcloud-v1' as a submodule to the OSDWorkspace Library-GitHub directory.

    .NOTES
        David Segura
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
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Start"
    Initialize-OSDWorkspace
    #=================================================
    # Requires Run as Administrator
    $IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $IsAdmin ) {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] This function must be Run as Administrator"
        return
    }
    #=================================================
    # Url must have a .git extension
    if ($Url -notlike '*.git') {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Url must have a .git extension"
        return
    }
    #=================================================
    # Url must be a GitHub hosted repository
    if ($Url.Authority -ne 'github.com') {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Url must be a GitHub hosted repository"
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
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] LibrarySubmodulePath: $LibrarySubmodulePath"

    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Repository Url to Add: $Url"
    
    $RepositoryName = (Split-Path $Url -Leaf).Replace('.git', '')
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Repository Name to Add: $RepositoryName"

    $Destination = "submodules/$RepositoryName"
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Repository Destination: $Destination"

    <#
    if (Test-Path -Path "$Destination\.git") {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Destination repository already exists"
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Use the Update-OSDWorkspaceSubmodule cmdlet to update this repository"
        return
    }
    #>
    #endregion
    #=================================================
    # Region Git Submodule Add
    # https://git-scm.com/docs/git-submodule
    # https://git-scm.com/book/en/v2/Git-Tools-Submodules
    # git submodule add <URL> <path>

    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Push-Location $OSDWorkspaceRoot"
    Push-Location $OSDWorkspaceRoot

    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] git submodule add $Url submodules/$RepositoryName"
    git submodule add $Url submodules/$RepositoryName

    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] git commit -m `"Add submodule $RepositoryName`""
    git commit -m "Add submodule $RepositoryName"

    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Pop-Location"
    Pop-Location
    #endregion
    #=================================================
    # Region Git Clone
    <#
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] git clone --verbose --progress --single-branch --depth 1 `"$Source`" `"$Destination`""
    git clone --verbose --progress --single-branch --depth 1 "$Source" "$Destination"

    if (Test-Path "$Destination\.git") {
        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Push-Location `"$Destination`""
        Push-Location "$Destination"

        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] git fetch --verbose --progress --depth 1 origin"
        git fetch --verbose --progress --depth 1 origin

        # Can leave this out since this is the first clone
        # Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] git reset --hard origin"
        # git reset --hard origin

        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] git clean -d --force"
        git clean -d --force

        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Pop-Location"
        Pop-Location
    }
    else {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Failed to clone repository"
    }
    #>
    #endregion
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}