function Import-OSDWorkspaceGitHubRepo {
    <#
    .SYNOPSIS
        Clones a GitHub Repository into C:\OSDWorkspace\Library-GitHub

    .DESCRIPTION
        Clones a GitHub Repository into C:\OSDWorkspace\Library-GitHub

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
    # Region Build the paths
    $Source = $Url
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Repository Source: $Source"

    # Destination Path
    $RepositoryParent = Get-OSDWorkspaceGitHubPath
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Repository Parent: $RepositoryParent"
    
    $RepositoryName = (Split-Path $Url -Leaf).Replace('.git', '')
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Repository Name: $RepositoryName"

    $Destination = Join-Path -Path $RepositoryParent -ChildPath $RepositoryName
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Repository Destination: $Destination"

    if (Test-Path -Path "$Destination\.git") {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Destination repository already exists"
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Use the Update-OSDWorkspaceGitHubRepo cmdlet to update this repository"
        return
    }
    #endregion
    #=================================================
    # Region Git Clone
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
    #endregion
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}