function Export-PSDriveWindowsImageIndex {
    [CmdletBinding()]
    param (
        [Parameter()]
        $Path
    )

    begin {
        #=================================================
        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
        $Error.Clear()
        $IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        if (-not $IsAdmin ) {
            Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] must be run with Administrator privileges"
            Break
        }
        #=================================================
        $WindowsMediaImage = @()
        $WindowsMediaImage = Get-PSDriveWindowsImageIndex -GridView Multiple
        #=================================================
    }

    process {
        foreach ($Item in $WindowsMediaImage) {
            $Guid = [Guid]::NewGuid().ToString()
            $FileName = (Split-Path $Item.ImagePath -Leaf).ToLower()

            $DestinationPath = $env:TEMP + "\$Guid"
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] DestinationPath: $DestinationPath"

            $DestinationImagePath = "$DestinationPath\$FileName"
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] DestinationImagePath: $DestinationImagePath"

            try {
                New-Item -Path $DestinationPath -ItemType Directory -Force -ErrorAction Stop | Out-Null
                Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Export WindowsImage"
                Export-WindowsImage -SourceImagePath $Item.ImagePath -SourceIndex $Item.ImageIndex -DestinationImagePath $DestinationImagePath -ErrorAction Stop | Out-Null

                Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Building information"
                $Image = Get-WindowsImage -ImagePath $DestinationImagePath -Index 1
                $Image | Export-Clixml -Path "$DestinationPath\os.xml"
                $Image | ConvertTo-Json | Out-File "$DestinationPath\os.json" -Encoding utf8
            }
            catch {
                throw $_
            }
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Output: Get-Item -Path $DestinationImagePath"
            Get-Item -Path $DestinationImagePath
        }
    }
    
    end {
        #=================================================
        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Done."
        #=================================================
    }
}