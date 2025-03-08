function Step-BootMediaLibraryBootMediaFile {
    [CmdletBinding()]
    param (
        [System.String]
        $MediaPath = $global:BuildMedia.MediaPath,
        [System.String]
        $MediaPathEX = $global:BuildMedia.MediaPathEX,
        $BootMediaFile = $global:BuildMedia.BootMediaFile,
        $BuildMediaLogs = $global:BuildMediaLogs
    )
    if ($BootMediaFile) {
        foreach ($Item in $BootMediaFile) {
            if ($Item -match '.zip') {
                Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Expanding BootMedia Files from $Item"
                Expand-Archive -Path $Item -Destination $MediaPath
                if ($MediaPathEX) {
                    Expand-Archive -Path $Item -Destination $MediaPathEX
                }
            }
            else {
                Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Copying BootMedia Files from $Item"
                $null = robocopy.exe "$Item" "$MediaPath" *.* /s /b /ndl /nfl /np /ts /r:0 /w:0 /xx /xj /mt:128 /LOG+:$BuildMediaLogs\Step-BootMediaLibraryBootMediaFile.log
                if ($MediaPathEX) {
                    $null = robocopy.exe "$Item" "$MediaPathEX" *.* /s /b /ndl /nfl /np /ts /r:0 /w:0 /xx /xj /mt:128 /LOG+:$BuildMediaLogs\Step-BootMediaLibraryBootMediaFile.log
                }
            }
        }
    }

}