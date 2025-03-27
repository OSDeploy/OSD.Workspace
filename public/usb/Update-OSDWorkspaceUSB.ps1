function Update-OSDWorkspaceUSB {
    <#
    .SYNOPSIS
        Creates a new OSDWorkspace USB.

    .DESCRIPTION
        This function creates a new OSDWorkspace USB by selecting a boot media and performing necessary checks and operations.

    .PARAMETER BootLabel
        Label for the boot partition. Default is 'WINPE'.

    .PARAMETER DataLabel
        Label for the data partition. Default is 'USB Data'.

    .INPUTS
        None.

        You cannot pipe input to this cmdlet.

    .OUTPUTS
        None.

        This function does not return any output.

    .EXAMPLE
        New-OSDWorkspaceUSB
        Creates a new OSDWorkspace USB with default labels for boot and data partitions.

    .EXAMPLE
        New-OSDWorkspaceUSB -BootLabel 'MYBOOT' -DataLabel 'MYDATA'
        Creates a new OSDWorkspace USB with the boot label 'MYBOOT' and data label 'MYDATA'.

    .NOTES
        David Segura
    #>
    [CmdletBinding()]
    param (
        [ValidateLength(0,11)]
        [string]$BootLabel = 'BootMedia',

        [ValidateLength(0,32)]
        [string]$DataLabel = 'USB-Data'
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
    # Set Variables
    $ErrorActionPreference = 'Stop'
    $MinimumSizeGB = 7
    $MaximumSizeGB = 2000
    #=================================================
    # Block
    Block-StandardUser
    Block-WindowsVersionNe10
    Block-PowerShellVersionLt5
    Block-WindowsReleaseIdLt1703
    #=================================================
    # Do we have a Boot Media?
    $SelectBootMedia = Select-OSDWSWinPEBuild

    if ($null -eq $SelectBootMedia) {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] No OSDWorkspace BootMedia was found or selected"
        return
    }
    #=================================================
    # Select a BootMedia Media folder
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Select an OSDWorkspace BootMedia to use with this USB (Cancel to exit)"
    $BootMediaObject = Get-ChildItem $($SelectBootMedia.Path) -Directory | Where-Object { ($_.Name -eq 'BootMedia') -or ($_.Name -eq 'BootMediaEx') } | Sort-Object Name, FullName | Select-Object Name, FullName | Out-GridView -Title 'Select an OSDWorkspace BootMedia to use with this USB (Cancel to exit)' -OutputMode Single
    if ($null -eq $BootMediaObject) {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] No BootMedia path was found"
        return
    }
    $BootMediaArch = $SelectBootMedia.Architecture.ToUpper()
    #$BootLabel = "WinPE-$($BootMediaArch)"
    #=================================================
    # Disable Autorun
    Set-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' -Name NoDriveTypeAutorun -Type DWord -Value 0xFF -ErrorAction SilentlyContinue
    #=================================================
    #	Update WinPE Volume
    #=================================================
    if (Test-Path -Path $BootMediaObject.FullName) {
        $WinpeVolumes = Get-USBVolume | Where-Object { $_.FileSystemLabel -eq 'BootMedia' }
        if ($WinpeVolumes) {
            Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying $($BootMediaObject.FullName) to USB BootMedia partitions"
            foreach ($volume in $WinpeVolumes) {
                if (Test-Path -Path "$($volume.DriveLetter):\") {
                    robocopy "$($BootMediaObject.FullName)" "$($volume.DriveLetter):\" *.* /e /ndl /r:0 /w:0 /xd '$RECYCLE.BIN' 'System Volume Information' /xj
                }
                $SelectBootMedia | ConvertTo-Json -Depth 5 | Out-File -FilePath "$($volume.DriveLetter):\object.json" -Force
            }
        }
        else {
            Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Unable to find a USB Partition labeled BootMedia to update"
        }
    }
    #=================================================
    #	Remove Read-Only Attribute
    #=================================================
    <#
    Get-ChildItem -Path $WinpeDestinationPath -File -Recurse -Force | ForEach-Object {
        Set-ItemProperty -Path $_.FullName -Name IsReadOnly -Value $false -Force -ErrorAction Ignore
    }
    #>
    #=================================================
    #	Return
    #=================================================
    Return (Get-OSDDisk -BusType USB -Number $SelectDisk.Number)
    #=================================================
}
