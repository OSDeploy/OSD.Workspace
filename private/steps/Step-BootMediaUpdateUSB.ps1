function Step-BootMediaUpdateUSB {
    [CmdletBinding()]
    param (
        [System.String]
        $UpdateUSB = $global:BootMedia.UpdateUSB,
        [System.String]
        $MediaPath = $global:BootMedia.MediaPath
    )
    if ($UpdateUSB) {
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
}