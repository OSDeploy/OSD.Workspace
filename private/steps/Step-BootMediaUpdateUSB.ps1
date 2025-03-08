function Step-BootMediaUpdateUSB {
    [CmdletBinding()]
    param (
        [System.String]
        $MediaPath = $global:BuildMedia.MediaPath,

        [System.Boolean]
        $UpdateUSB = $global:BuildMedia.UpdateUSB
    )
    #=================================================
    $Error.Clear()
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] MediaPath: $MediaPath"
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] UpdateUSB: $UpdateUSB"
    #=================================================
    if ($UpdateUSB -eq $true) {
        Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Update USB BootMedia Partition"
        $WinpeVolumes = Get-USBVolume | Where-Object { $_.FileSystemLabel -eq 'BootMedia' }
        if ($WinpeVolumes) {
            foreach ($volume in $WinpeVolumes) {
                if (Test-Path -Path "$($volume.DriveLetter):\") {
                    robocopy "$MediaPath" "$($volume.DriveLetter):\" *.* /e /ndl /np /r:0 /w:0 /xd '$RECYCLE.BIN' 'System Volume Information' /xj
                }
            }
        }
        else {
            Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Unable to find a USB Partition labeled BootMedia to update"
        }
    }
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}