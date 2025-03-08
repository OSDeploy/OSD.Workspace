function Step-BuildMediaLibraryWinPEFile {
    [CmdletBinding()]
    param (
        [System.String]
        $MountPath = $global:BuildMedia.MountPath,
        $LibraryWinPEFile = $global:BuildMedia.LibraryWinPEFile,
        [System.String]
        $LogsPath = $global:BuildMediaLogsPath
    )
    #=================================================
    $Error.Clear()
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] MountPath: $MountPath"
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] LibraryWinPEFile: $LibraryWinPEFile"
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] LogsPath: $LogsPath"
    #=================================================
    foreach ($Item in $LibraryWinPEFile) {
        if (Test-Path $Item) {
            if ($Item -match '.zip') {
                Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Expanding BootImage Files from $Item"
                Expand-Archive -Path $Item -Destination $MountPath
            }
            else {
                Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Copying BootImage Files from $Item"
                $null = robocopy.exe "$Item" "$MountPath" *.* /s /b /ndl /nfl /np /ts /r:0 /w:0 /xx /xj /mt:128 /LOG+:"$LogsPath\Step-BuildMediaLibraryWinPEFile.log"
            }
        }
        else {
            Write-Warning "BootImage File $Item (not found)"
        }
    }
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}