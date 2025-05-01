function Step-BuildMediaGetContentStartnet {
    [CmdletBinding()]
    param (
        [System.String]
        $MountPath = $global:BuildMedia.MountPath
    )
    #=================================================
    $Error.Clear()
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Start"
    #=================================================
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] MountPath: $MountPath"
    #=================================================
    if (Test-Path "$MountPath\Windows\System32\startnet.cmd") {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Startnet.cmd Content"
        [System.String]$ContentStartnet = Get-Content -Path "$MountPath\Windows\System32\startnet.cmd" -Raw
        $global:BuildMedia.ContentStartnet = $ContentStartnet
        $global:BuildMedia.ContentStartnet | Out-Host
    }
    #=================================================
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}