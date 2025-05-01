function Step-BuildMediaUpdateUSB {
    [CmdletBinding()]
    param (
        [System.String]
        $MediaPath = $global:BuildMedia.MediaPath,
        [System.Boolean]
        $UpdateUSB = $global:BuildMedia.UpdateUSB
    )
    #=================================================
    $Error.Clear()
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Start"
    #=================================================
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] MediaPath: $MediaPath"
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] UpdateUSB: $UpdateUSB"
    #=================================================
    if ($UpdateUSB -eq $true) {
        Write-Host -ForegroundColor DarkCyan "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Update USB-WinPE Partition"
        $WinpeVolumes = Get-USBVolume | Where-Object { $_.FileSystemLabel -eq 'USB-WinPE' }
        if ($WinpeVolumes) {
            foreach ($volume in $WinpeVolumes) {
                if (Test-Path -Path "$($volume.DriveLetter):\") {
                    robocopy "$MediaPath" "$($volume.DriveLetter):\" *.* /e /ndl /np /r:0 /w:0 /xd '$RECYCLE.BIN' 'System Volume Information' /xj
                }
            }
        }
        else {
            Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Unable to find a USB Partition labeled USB-WinPE to update"
        }
    }
    #=================================================
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}