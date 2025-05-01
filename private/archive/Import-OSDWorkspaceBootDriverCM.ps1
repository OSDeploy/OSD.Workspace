function Import-OSDWorkspaceBootDriverCM {
    <#
    .SYNOPSIS
    Imports OSDWorkspace BootDrivers into Configuration Manager.

    .DESCRIPTION
    This function allows you to Select amd64 or arm64 Drivers from your OSDWorkspace BootDriver or BootDriver-Repos folder, Copy the files to a Source Folder, then Imports the drivers into Configuration Manager.

    .PARAMETER SiteServer
    FQDN of the Configuration Manager Site Server. Will get Site Code from CIM on this server.

    .PARAMETER SourcePath
    Path to the Source Folder where the Drivers will be copied to.
    This needs to be a UNC path accessible from the Configuration Manager Site Server.

    .PARAMETER Architecture
    Architecture of the Drivers to Import. Valid values are amd64 or arm64.

    .EXAMPLE
    Import-OSDWorkspaceBootDriverCM -SiteServer "MEMCM.contoso.com" -SourcePath "\\MEMCM-Dev\Source$\Drivers" -Architecture "amd64"

    .NOTES
    SourcePath will build the same folder structure as the BootDriver folder.
    Will create a new Category "OSDWorkspace" if it does not exist.
    Will create a new CM Driver Folder "OSDWorkspace\$Architecture" if it does not exist.

    .LINK
    Add Docs Link Here
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [System.String]
        $SiteServer,

        [Parameter(Mandatory = $true)]
        [System.String]
        $SourcePath,

        [Parameter(Mandatory = $true)]
        [ValidateSet('amd64', 'arm64')]
        [System.String]
        $Architecture
    )
    #=================================================
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] $($MyInvocation.MyCommand) Start"
    $Error.Clear()
    #=================================================
    #region Import the Configuration Manager module
    try {
        Import-Module "$(${env:ProgramFiles(x86)})\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1" -ErrorAction Stop
    }
    catch {
        Write-Error "Microsoft Configuration Manager Console is not installed, required for PSModule"
        Break
    }
    #endregion
    #=================================================
    #region Determine Site Code
    # https://github.com/MSEndpointMgr/ConfigMgrContentSourceUpdateTool/blob/main/Update-ConfigMgrContentSourceGUI_1.0.2.ps1
    try {
        $SiteProviders = Get-CimInstance -Namespace "root\SMS" -Class SMS_ProviderLocation -ComputerName "$($SiteServer)" -ErrorAction Stop
        foreach ($Provider in $SiteProviders) {
            if ($Provider.ProviderForLocalSite -eq $true) {
                $SiteCode = $Provider.SiteCode
            }
        }
    }
    catch [System.UnauthorizedAccessException] {
        Write-Warning -Message "Access denied" ; break
    }
    catch [System.Exception] {
        Write-Warning -Message "Unable to determine Site Code" ; break
    }
    #endregion
    #=================================================
    # Select BootDriver
    $WinPEDriver = Select-OSDWSWinPEBuildDriver -Architecture $Architecture

    foreach ($Driver in $WinPEDriver) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Boot Driver: [$($Driver.FullName)]"
        #=================================================
        #region Build Driver Source Path
        if ($Driver.FullName -match '\\BootDriver-Repos\\') {
            $DriverSourceFolder = Join-Path "OSDWorkspace" "$(($Driver.FullName -split '\\')[-4..-2] -join '\')"
        }
        else {
            $DriverSourceFolder = Join-Path "OSDWorkspace" "$(($Driver.FullName -split '\\')[-3..-2] -join '\')"
        }        
        $DriverSourceFolder = Join-Path "$($SourcePath)" "$($DriverSourceFolder)"
        if (! (Test-Path "$($DriverSourceFolder)")) {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Creating Source Directory: [$($DriverSourceFolder)]"
            New-Item -Path "$($DriverSourceFolder)" -ItemType Directory | Out-Null
        }
        #endregion
        #=================================================
        #region Copy Drivers to Source Directory
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Copying Drivers to Source Directory"
        Copy-Item -Path $($Driver.FullName) -Destination "$($DriverSourceFolder)" -Recurse -Force | Out-Null
        #endregion
        #=================================================
        #region Connect to Configuration Manager
        try {
            # Set Location to site
            Push-Location "$($SiteCode):\"
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Successfully connected to the Configuration Manager site: [$SiteCode]"
        }
        catch {
            Write-Error "Failed to connect to the Configuration Manager site"
            Break
        }
        #endregion
        #=================================================
        #region Create CM Category
        $CMCategory = Get-CMCategory -CategoryType DriverCategories -Name "OSDWorkspace"
        if ($null -eq $CMCategory) {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Creating CM Category: [OSDWorkspace]"
            $CMCategory = New-CMCategory -CategoryType DriverCategories -Name "OSDWorkspace"
        }
        #endregion
        #=================================================
        #region Create CM Root Driver Folder
        $CMRootFolder = Get-CMFolder -ParentFolderPath Driver -Name "OSDWorkspace"
        if ($null -eq $CMRootFolder) {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Creating CM Driver Folder: [OSDWorkspace]"
            $CMRootFolder = New-CMFolder -ParentFolderPath Driver -Name "OSDWorkspace"
        }
        #endregion
        #=================================================
        #region Create CM Sub Driver Folder
        $CMSubFolder = Get-CMFolder -FolderPath "Driver\$($CMRootFolder.Name)\$($Architecture)"
        if ($null -eq $CMSubFolder) {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Creating CM Sub Driver Folder: [$($($Architecture))]"
            $CMSubFolder = New-CMFolder -ParentFolderPath "Driver\$($CMRootFolder.Name)" -Name "$($($Architecture))"
        }
        #endregion
        #=================================================
        #region Import Drivers
        Write-Host -ForegroundColor DarkCyan "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Importing Drivers from: [$(Join-Path $DriverSourceFolder $Driver.Name)]"
        $ImportedDrivers = $null
        try {
            $ImportedDrivers = Import-CMDriver -Path "$(Join-Path $DriverSourceFolder $Driver.Name)" -ImportFolder -AdministrativeCategory $CMCategory -ImportDuplicateDriverOption AppendCategory

            # Move Drivers to CM Folder
            Move-CMObject -InputObject $ImportedDrivers -FolderPath "$($SiteCode):\Driver\$($CMRootFolder.Name)\$($CMSubFolder.Name)"
            
            Write-Host -ForegroundColor Green "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Successfully Imported Drivers"
        }
        catch {
            Write-Error "Failed to Import Drivers: [$($DriverFile.FullName)]"
            Write-Error "$($_.Exception.Message)"
        }
        #endregion
        #=================================================
        # Return to the previous location
        Pop-Location
    }
    #=================================================
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] $($MyInvocation.MyCommand) End"
    #=================================================
}