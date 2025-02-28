function Get-PSDriveWindowsImageIndex {
    [CmdletBinding()]
    param (
        [ValidateSet('Single', 'Multiple')]
        [System.String]
        $GridView
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
    $PSDriveWindowsImageFile = @()
    $PSDriveWindowsImageFile = Find-PSDriveWindowsImage
    #=================================================
    if ($PSDriveWindowsImageFile) {
        $WindowsMediaImages = $PSDriveWindowsImageFile | ForEach-Object {
            # Set the MediaRoot
            $MediaRoot = $_.MediaRoot
            Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] WindowsImage: $($_.FullName)"
            Get-WindowsImage -ImagePath "$($_.FullName)"
        } | ForEach-Object {
            Get-WindowsImage -ImagePath "$($_.ImagePath)" -Index $($_.ImageIndex) | Select-Object -Property @{Name = 'MediaRoot'; Expression = { $MediaRoot } }, *
            Write-Host "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] ImageIndex $($_.ImageIndex): $($_.ImageName)" -ForegroundColor DarkGray
        }

        # Set Architecture to human readable"
        foreach ($Image in $WindowsMediaImages) {
            if ($Image.Architecture -eq '0') { $Image.Architecture = 'x86' }
            if ($Image.Architecture -eq '1') { $Image.Architecture = 'MIPS' }
            if ($Image.Architecture -eq '2') { $Image.Architecture = 'Alpha' }
            if ($Image.Architecture -eq '3') { $Image.Architecture = 'PowerPC' }
            if ($Image.Architecture -eq '5') { $Image.Architecture = 'ARM' }
            if ($Image.Architecture -eq '6') { $Image.Architecture = 'ia64' }
            if ($Image.Architecture -eq '9') { $Image.Architecture = 'amd64' }
            if ($Image.Architecture -eq '12') { $Image.Architecture = 'arm64' }
        }

        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Building results"
        $Results = $WindowsMediaImages | Select-Object -Property MediaRoot, ImagePath, ImageIndex, ImageName, Architecture, Version, EditionId, Languages, `
            InstallationType, CreatedTime, ModifiedTime, `
            DirectoryCount, FileCount, ImageDescription, ImageSize, ImageType, WIMBoot, ProductName, Hal, ProductSuite, ProductType, `
            MajorVersion, MinorVersion, Build, SPBuild, SPLevel, ImageBootable, SystemRoot, DefaultLanguageIndex, LogPath, ScratchDirectory, LogLevel


        if ($Gridview) {
            $Results = $Results | Out-GridView -Title 'Select a WindowsImage and press OK (Cancel to Exit)' -OutputMode $GridView
        }

        return $Results
    }
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}