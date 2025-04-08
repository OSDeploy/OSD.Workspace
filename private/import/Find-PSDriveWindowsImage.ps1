function Find-PSDriveWindowsImage {
    [CmdletBinding()]
    param ()
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Start"
    $Error.Clear()
    $IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $IsAdmin ) {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] must be run with Administrator privileges"
        Break
    }
    #=================================================
    #region Find PSDrive Windows Media
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Building PSDrive array containing Windows Media, including Mounted ISOs"
    $WindowsMediaDrives = @()
    $WindowsMediaDrives = Get-PSDrive -PSProvider 'FileSystem' | `
        Where-Object { ($_.Name).Length -eq 1 } | `
        Where-Object { $_.Name -match '^[D-Z]' } | `
        Where-Object { $_.Root -match '^[D-Z]:\\' }

    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Found $($WindowsMediaDrives.Count) PSDrives"

    $WindowsMediaSources = @()
    foreach ($Drive in $WindowsMediaDrives) {
        if (Test-Path "$($Drive.Root)Sources") {
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Gathering WindowsImage information from $($Drive.Root)Sources"
            $WindowsMediaSources += Get-ChildItem "$($Drive.Root)Sources\*" -Include install.wim, install.esd -ErrorAction SilentlyContinue | `
                Select-Object -Property @{Name = 'MediaRoot'; Expression = { (Get-Item $_.Directory).Parent.FullName } }, *
        }
        if (Test-Path "$($Drive.Root)x64\Sources") {
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Gathering WindowsImage information from $($Drive.Root)x64\Sources"
            $WindowsMediaSources += Get-ChildItem "$($Drive.Root)x64\Sources\*" -Include install.wim, install.esd -ErrorAction SilentlyContinue | `
                Select-Object -Property @{Name = 'MediaRoot'; Expression = { (Get-Item $_.Directory).Parent.FullName } }, *
        }
        if (Test-Path "$($Drive.Root)x86\Sources") {
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Gathering WindowsImage information from $($Drive.Root)x86\Sources"
            $WindowsMediaSources += Get-ChildItem "$($Drive.Root)x86\Sources\*" -Include install.wim, install.esd -ErrorAction SilentlyContinue | `
                Select-Object -Property @{Name = 'MediaRoot'; Expression = { (Get-Item $_.Directory).Parent.FullName } }, *
        }
    }

    if ($WindowsMediaSources) {
        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Returning WindowsMediaSources"
        return $WindowsMediaSources
    }
    else {
        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] No WindowsMediaSources"
        return $null
    }
    #endregion
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}