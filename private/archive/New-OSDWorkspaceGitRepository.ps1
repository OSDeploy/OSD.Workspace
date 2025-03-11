function New-OSDWorkspaceGitRepository {
    <#
    .SYNOPSIS
        Creats a new OSDWorkspace Repository and initializes it with Git.

    .DESCRIPTION
        Creats a new OSDWorkspace Repository and initializes it with Git.

    .NOTES
        David Segura
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        # Filters the drivers by boot image (ADK, WinPE, WinRE) by excluding Wireless drivers for ADK and WinPE
        [ValidateSet('BootDriver', 'Library')]
        [System.String]
        $Type
    )
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
    $Error.Clear()
    $IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $IsAdmin ) {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] must be run with Administrator privileges"
        Break
    }
    #=================================================
    # Region Destination Path
    if ($Type -eq 'BootDriver') {
        $RepositoryParent = Get-OSDWorkspaceLibraryGitBootDriverPath
    }
    elseif ($Type -eq 'Library') {
        $RepositoryParent = Get-OSDWSLibraryRemotePath
    }
    else {
        Write-Error "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Invalid Content: $Type"
        return
    }
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Repository Parent: $RepositoryParent"
    
    $Destination = Join-Path -Path $RepositoryParent -ChildPath $Name
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Repository Destination: $Destination"

    if (Test-Path -Path "$Destination" -ErrorAction SilentlyContinue) {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Destination repository already exists"
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Use the Update-OSDWorkspaceRemoteLibrary cmdlet to update this repository"
        return
    }
    #endregion
    #=================================================
    # Region Git Init
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] git init `"$Destination`""
    git init "$Destination"

    if (($Type -eq 'BootDriver') -and (Test-Path -Path $Destination)) {
        New-Item -Path "$Destination\amd64\Manufacturer-Model" -ItemType Directory -Force | Out-Null
        New-Item -Path "$Destination\arm64\Manufacturer-Model" -ItemType Directory -Force | Out-Null
    }
    else {
        # New-Item -Path "$Destination\WinPE-File" -ItemType Directory -Force | Out-Null
        New-Item -Path "$Destination\WinPE-Script" -ItemType Directory -Force | Out-Null
        # New-Item -Path "$Destination\WinPE-Startnet" -ItemType Directory -Force | Out-Null
        # New-Item -Path "$Destination\WinPE-MediaFile" -ItemType Directory -Force | Out-Null
        New-Item -Path "$Destination\WinPE-BuildProfile" -ItemType Directory -Force | Out-Null
        New-Item -Path "$Destination\WinPE-MediaScript" -ItemType Directory -Force | Out-Null
    }

    Get-Item -Path $Destination
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}