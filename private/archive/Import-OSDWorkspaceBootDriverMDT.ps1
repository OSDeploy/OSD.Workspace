
function Import-OSDWorkspaceBootDriverMDT {
    <#
    .SYNOPSIS
        Imports OSDWorkspace BootDrivers into Microsoft Deployment Toolkit

    .DESCRIPTION
        This function allows you to Select amd64 Drivers from your OSDWorkspace BootDriver or BootDriver-Repos folder, then Imports the drivers into Microsoft Deployment Toolkit.

    .PARAMETER ShareName
        Name of the Deployment Share to Import the Drivers into.

    .EXAMPLE
        Import-OSDWorkspaceBootDriverMDT -ShareName "MDTShare"

    .NOTES
        If 'ShareName' is not specified, the function will use the current MDT Persistent Drive on the Running Machine.
        The function will create a new Selection Profile "OSDWorkspace WinPE amd64" if it does not exist.
        The function will create a new Out-of-Box Drivers folder "OSDWorkspace WinPE amd64" if it does not exist.

    .LINK
        Add Docs Links Here
    #>
    [CmdletBinding()]
    param (
        [Alias('Share')]
        [System.String]
        $ShareName
    )
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
    $Error.Clear()
    #=================================================
    #region Impor the Microsoft Deployment Toolkit module
    try {
        Import-Module "$env:ProgramFiles\Microsoft Deployment Toolkit\bin\MicrosoftDeploymentToolkit.psd1"
    }
    catch {
        Write-Error 'Microsoft Deployment Toolkit is not installed'
        Break
    }
    #endregion
    #=================================================
    #region Determine the MDT Persistent Drive
    if ((Get-MDTPersistentDrive).Length -lt 2) {
        $MDTPersistentDrive = (Get-MDTPersistentDrive).Path
    }
    else {
        $MDTPersistentDrive = $ShareName
    }

    if ($MDTPersistentDrive) {
        $MDTPSDrive = New-PSDrive -Name 'OSDWorkspace' -PSProvider MDTProvider -Root $MDTPersistentDrive -ErrorAction SilentlyContinue
    }
    #endregion
    #=================================================
    if ($MDTPSDrive) {
        #=================================================
        #region Modify the 'Settings.xml' file for the Deployment Share
        Set-ItemProperty -Path "$($MDTPSDrive.Name):" -Name SupportX64 -Value 'True'
        Set-ItemProperty -Path "$($MDTPSDrive.Name):" -Name Boot.x64.UseBootWim -Value 'True'
        Set-ItemProperty -Path "$($MDTPSDrive.Name):" -Name Boot.x64.IncludeNetworkDrivers -Value 'True'
        Set-ItemProperty -Path "$($MDTPSDrive.Name):" -Name Boot.x64.IncludeMassStorageDrivers -Value 'True'
        Set-ItemProperty -Path "$($MDTPSDrive.Name):" -Name Boot.x64.IncludeVideoDrivers -Value 'False'
        Set-ItemProperty -Path "$($MDTPSDrive.Name):" -Name Boot.x64.IncludeSystemDrivers -Value 'True'
        Set-ItemProperty -Path "$($MDTPSDrive.Name):" -Name Boot.x64.IncludeAllDrivers -Value 'True'

        <#
        #Set-ItemProperty -Path "$($MDTPSDrive.Name):" -Name SupportX86 -Value 'False'
        #Set-ItemProperty -Path "$($MDTPSDrive.Name):" -Name Boot.x64.GenerateGenericWIM -Value 'False'
        #Set-ItemProperty -Path "$($MDTPSDrive.Name):" -Name Boot.x64.GenerateGenericISO -Value 'False'
        #Set-ItemProperty -Path "$($MDTPSDrive.Name):" -Name Boot.x64.GenerateLiteTouchISO -Value 'True'
        #Set-ItemProperty -Path "$($MDTPSDrive.Name):" -Name Boot.x64.ScratchSpace -Value '512'
        #Set-ItemProperty -Path "$($MDTPSDrive.Name):" -Name Boot.x64.SelectionProfile -Value 'WinPE amd64'
        #Set-ItemProperty -Path "$($MDTPSDrive.Name):" -Name Boot.x64.SupportUEFI -Value 'True'
        #>
        #endregion
        #=================================================
        #region Create Selection Profile
        if (! (Test-Path "$($MDTPSDrive.Name):\Selection Profiles\OSDWorkspace WinPE amd64")) {
            New-Item -Path "$($MDTPSDrive.Name):\Selection Profiles" -Enable 'True' -Name 'OSDWorkspace WinPE amd64' -Comments 'OSDWorkspace WinPE amd64' -Definition "<SelectionProfile><Include path=`"Out-of-Box Drivers\OSDWorkspace WinPE amd64`"></Include></SelectionProfile>" -ReadOnly 'False' -Verbose
        }
        #endregion
        #=================================================
        #region Create Directory for WinPE
        if (! (Test-Path "$($MDTPSDrive.Name):\Out-of-Box Drivers\OSDWorkspace WinPE amd64")) {
            New-Item -Path "$($MDTPSDrive.Name):\Out-of-Box Drivers" -Enable 'True' -Name 'OSDWorkspace WinPE amd64' -Comments 'OSDWorkspace WinPE amd64' -ItemType Folder -Verbose
        }
        #endregion
        #=================================================
        #region WinPE
        $LibraryWinPEDriver = Select-OSDWorkspaceLibraryWinPEDriver -Architecture 'amd64'
        foreach ($Driver in $LibraryWinPEDriver) {
            if (! (Test-Path "$($MDTPSDrive.Name):\Out-of-Box Drivers\OSDWorkspace WinPE amd64")) {
                New-Item -Path "$($MDTPSDrive.Name):\Out-of-Box Drivers" -Enable 'True' -Name "OSDWorkspace WinPE amd64" -Comments '' -ItemType Folder -Verbose
            }
            Import-MDTDriver -Path "$($MDTPSDrive.Name):\Out-of-Box Drivers\OSDWorkspace WinPE amd64" -SourcePath $Driver.FullName -Verbose
        }
        #endregion
        #=================================================
        # Remove the MDT PSDrive
        Remove-PSDrive -Name "$($MDTPSDrive.Name)" -ErrorAction SilentlyContinue
    }
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}