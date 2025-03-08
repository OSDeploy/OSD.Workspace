function Step-BootImageLibraryBootImageFile {
    [CmdletBinding()]
    param (
        [System.String]
        $MountPath = $global:BuildMedia.MountPath,
        $BootImageFile = $global:BuildMedia.BootImageFile
    )
    foreach ($Item in $BootImageFile) {
        if (Test-Path $Item) {
            if ($Item -match '.zip') {
                Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Expanding BootImage Files from $Item"
                Expand-Archive -Path $Item -Destination $MountPath
            }
            else {
                Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Copying BootImage Files from $Item"
                $null = robocopy.exe "$Item" "$MountPath" *.* /s /b /ndl /nfl /np /ts /r:0 /w:0 /xx /xj /mt:128 /LOG+:$BuildMediaLogs\Step-BootImageLibraryBootImageFile.log
            }
        }
        else {
            Write-Warning "BootImage File $Item (not found)"
        }
    }
}