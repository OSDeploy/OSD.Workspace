function Step-BuildMediaLibraryMediaFile {
    [CmdletBinding()]
    param (
        [System.String]
        $MediaPath = $global:BuildMedia.MediaPath,
        [System.String]
        $MediaPathEX = $global:BuildMedia.MediaPathEX,
        $LibraryMediaFile = $global:BuildMedia.MediaFile,
        [System.String]
        $LogsPath = $global:BuildMediaLogsPath
    )
    #=================================================
    $Error.Clear()
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Start"
    #=================================================
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] MountPath: $MediaPath"
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] MediaPathEX: $MediaPathEX"
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] LibraryMediaFile: $LibraryMediaFile"
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] LogsPath: $LogsPath"
    #=================================================
    if ($LibraryMediaFile) {
        foreach ($Item in $LibraryMediaFile) {
            if ($Item -match '.zip') {
                Write-Host -ForegroundColor DarkCyan "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Expanding BootMedia Files from $Item"
                Expand-Archive -Path $Item -Destination $MediaPath
                if ($MediaPathEX) {
                    Expand-Archive -Path $Item -Destination $MediaPathEX
                }
            }
            else {
                Write-Host -ForegroundColor DarkCyan "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Copying BootMedia Files from $Item"
                $null = robocopy.exe "$Item" "$MediaPath" *.* /s /b /ndl /nfl /np /ts /r:0 /w:0 /xx /xj /mt:128 /LOG+:$LogsPath\Step-BuildMediaLibraryMediaFile.log
                if ($MediaPathEX) {
                    $null = robocopy.exe "$Item" "$MediaPathEX" *.* /s /b /ndl /nfl /np /ts /r:0 /w:0 /xx /xj /mt:128 /LOG+:$LogsPath\Step-BuildMediaLibraryMediaFile.log
                }
            }
        }
    }
    #=================================================
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}