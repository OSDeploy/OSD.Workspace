function Add-OSDWorkspaceSubmodule {
    <#
    .SYNOPSIS
        Clones a GitHub Repository into C:\OSDWorkspace\Library-GitHub

    .DESCRIPTION
        This function clones a specified GitHub repository into the OSDWorkspace Library-GitHub directory.
        Performs a fetch and clean operation to ensure the repository is up to date and free of untracked files.
        If you have already cloned the repository, use the Update-OSDWorkspaceSubmodule cmdlet to update it.

    .INPUTS
        None.

        You cannot pipe input to this cmdlet.

    .OUTPUTS
        None.

        This function does not return any output.

    .EXAMPLE
        Add-OSDWorkspaceSubmodule -Url 'https://github.com/MichaelEscamilla/OSDWorkspace-MichaelEscamilla.git'
        Clones the repository 'OSDWorkspace-MichaelEscamilla' into the OSDWorkspace Library-GitHub directory.
        #TODO Update URL to the OSDWorkspace Template GitHub Repository

    .LINK
    https://github.com/OSDeploy/OSD.Workspace/blob/main/docs/Add-OSDWorkspaceSubmodule.md

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
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
    Initialize-OSDWorkspace
    #=================================================
    # Requires Run as Administrator
    $IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $IsAdmin ) {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] This function must be Run as Administrator"
        return
    }
    #=================================================
    # Url must have a .git extension
    if ($Url -notlike '*.git') {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Url must have a .git extension"
        return
    }
    #=================================================
    # Url must be a GitHub hosted repository
    if ($Url.Authority -ne 'github.com') {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Url must be a GitHub hosted repository"
        return
    }
    #=================================================
    # Get Paths
    $OSDWorkspaceRoot = $OSDWorkspace.path
    $LibrarySubmodulePath = $OSDWorkspace.paths.submodules
    #=================================================
    # Create submodules
    if (-not (Test-Path $LibrarySubmodulePath -ErrorAction SilentlyContinue)) {
        New-Item -Path $LibrarySubmodulePath -ItemType Directory -Force | Out-Null
    }
    #=================================================
    # Region Build the paths
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] LibrarySubmodulePath: $LibrarySubmodulePath"

    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Repository Url to Add: $Url"
    
    $RepositoryName = (Split-Path $Url -Leaf).Replace('.git', '')
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Repository Name to Add: $RepositoryName"

    $Destination = "submodules/$RepositoryName"
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Repository Destination: $Destination"

    <#
    if (Test-Path -Path "$Destination\.git") {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Destination repository already exists"
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Use the Update-OSDWorkspaceSubmodule cmdlet to update this repository"
        return
    }
    #>
    #endregion
    #=================================================
    # Region Git Submodule Add
    # https://git-scm.com/docs/git-submodule
    # https://git-scm.com/book/en/v2/Git-Tools-Submodules
    # git submodule add <URL> <path>

    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Push-Location $OSDWorkspaceRoot"
    Push-Location $OSDWorkspaceRoot

    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] git submodule add $Url submodules/$RepositoryName"
    git submodule add $Url submodules/$RepositoryName

    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] git commit -m `"Add submodule $RepositoryName`""
    git commit -m "Add submodule $RepositoryName"

    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Pop-Location"
    Pop-Location
    #endregion
    #=================================================
    # Region Git Clone
    <#
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] git clone --verbose --progress --single-branch --depth 1 `"$Source`" `"$Destination`""
    git clone --verbose --progress --single-branch --depth 1 "$Source" "$Destination"

    if (Test-Path "$Destination\.git") {
        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Push-Location `"$Destination`""
        Push-Location "$Destination"

        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] git fetch --verbose --progress --depth 1 origin"
        git fetch --verbose --progress --depth 1 origin

        # Can leave this out since this is the first clone
        # Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] git reset --hard origin"
        # git reset --hard origin

        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] git clean -d --force"
        git clean -d --force

        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Pop-Location"
        Pop-Location
    }
    else {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Failed to clone repository"
    }
    #>
    #endregion
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}