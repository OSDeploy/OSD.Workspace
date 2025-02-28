function Find-PSDriveBootImage {
    [CmdletBinding()]
    [OutputType([System.IO.FileSystemInfo])]
    param ()
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
    $Error.Clear()
    #Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
    $IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $IsAdmin ) {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] must be run with Administrator privileges"
        Break
    }
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Building PSDrive array containing Windows Media, including Mounted ISOs"
    $WindowsMediaDrives = @()
    $WindowsMediaDrives = Get-PSDrive -PSProvider 'FileSystem' | `
    Where-Object { ($_.Name).Length -eq 1 } | `
    Where-Object { $_.Name -match '^[D-Z]' } | `
    Where-Object { $_.Root -match '^[D-Z]:\\' }

    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Found $($WindowsMediaDrives.Count) PSDrives containing Windows Media"
    $WindowsMediaSources = @()
    foreach ($Drive in $WindowsMediaDrives) {
        if (Test-Path "$($Drive.Root)Sources") {
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Gathering WindowsImage information from $($Drive.Root)Sources"
            $WindowsMediaSources += Get-ChildItem "$($Drive.Root)Sources\*" -Include boot.wim -ErrorAction SilentlyContinue | `
            Select-Object -Property @{Name = 'MediaRoot'; Expression = { (Get-Item $_.Directory).Parent.FullName } }, *
        }
        if (Test-Path "$($Drive.Root)x64\Sources") {
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Gathering WindowsImage information from $($Drive.Root)x64\Sources"
            $WindowsMediaSources += Get-ChildItem "$($Drive.Root)x64\Sources\*" -Include boot.wim -ErrorAction SilentlyContinue | `
            Select-Object -Property @{Name = 'MediaRoot'; Expression = { (Get-Item $_.Directory).Parent.FullName } }, *
        }
        if (Test-Path "$($Drive.Root)x86\Sources") {
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Gathering WindowsImage information from $($Drive.Root)x86\Sources"
            $WindowsMediaSources += Get-ChildItem "$($Drive.Root)x86\Sources\*" -Include boot.wim -ErrorAction SilentlyContinue | `
            Select-Object -Property @{Name = 'MediaRoot'; Expression = { (Get-Item $_.Directory).Parent.FullName } }, *
        }
    }

    if ($WindowsMediaSources) {
        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Returning System.IO.FileSystemInfo object"
        return $WindowsMediaSources
    }
    else {
        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] No Windows Media found"
        return $null
    }
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}