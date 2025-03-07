function Export-PSDriveWindowsImageIndex {
    [CmdletBinding()]
    param (
        [Parameter()]
        $Path
    )

    begin {
        #=================================================
        $Error.Clear()
        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
        #=================================================
        $IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        if (-not $IsAdmin ) {
            Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] This function must be Run as Administrator"
            return
        }
        #=================================================
        $WindowsMediaImages = @()
        $WindowsMediaImages = Get-PSDriveWindowsImageIndex -GridView Multiple
        #=================================================
    }

    process {
        #=================================================
        foreach ($SourceWindowsImage in $WindowsMediaImages) {
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] foreach"

            # Set the BuildDateTime
            $BuildDateTime = $((Get-Date).ToString('yyMMdd-HHmmss'))
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] BuildDateTime: $BuildDateTime]"

            # Set the Architecture
            $Architecture = $SourceWindowsImage.Architecture
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Architecture: $Architecture]"

            # Set the Destination Name
            $DestinationName = "$BuildDateTime $Architecture"
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] DestinationName: $DestinationName]"
            
            # Set the Destination Path
            $DestinationDirectory = Join-Path $env:Temp "$DestinationName"
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] DestinationDirectory: $DestinationDirectory"

            $DestinationCore = "$DestinationDirectory\.core"
            $DestinationTemp = "$DestinationDirectory\.temp"
            $DestinationLogs = "$DestinationTemp\logs"
            $DestinationWim = "$DestinationDirectory\.wim"
            $DestinationMedia = "$DestinationDirectory\OSMedia"

            New-Item -Path $DestinationCore -ItemType Directory -Force -ErrorAction Stop | Out-Null
            New-Item -Path $DestinationLogs -ItemType Directory -Force -ErrorAction Stop | Out-Null
            New-Item -Path $DestinationWim -ItemType Directory -Force -ErrorAction Stop | Out-Null
            New-Item -Path $DestinationMedia -ItemType Directory -Force -ErrorAction Stop | Out-Null

            $ImportId = @{id = $DestinationName }
            $ImportId | ConvertTo-Json | Out-File "$DestinationCore\id.json" -Encoding utf8






            $Guid = [Guid]::NewGuid().ToString()
            $FileName = (Split-Path $SourceWindowsImage.ImagePath -Leaf).ToLower()

            $DestinationPath = $env:TEMP + "\$Guid"
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] DestinationPath: $DestinationPath"

            $DestinationImagePath = "$DestinationPath\$FileName"
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] DestinationImagePath: $DestinationImagePath"

            try {
                # Export the Operating System install.wim
                $NewItem = New-Item -Path $DestinationPath -ItemType Directory -Force -ErrorAction Stop
                Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Export WindowsImage to $DestinationImagePath"
                $ExportWindowsImage = Export-WindowsImage -SourceImagePath $SourceWindowsImage.ImagePath -SourceIndex $SourceWindowsImage.ImageIndex -DestinationImagePath $DestinationImagePath -ErrorAction Stop

                # Export the Operating System information
                $Image = Get-WindowsImage -ImagePath $DestinationImagePath -Index 1

                Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Export $DestinationPath\os-WindowsImage.xml"
                $Image | Export-Clixml -Path "$DestinationPath\os-WindowsImage.xml"
                
                Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Export $DestinationPath\os-WindowsImage.json"
                $Image | ConvertTo-Json | Out-File "$DestinationPath\os-WindowsImage.json" -Encoding utf8
            }
            catch {
                throw $_
            }

            
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Output: Get-Item -Path $DestinationImagePath"
            $(Get-Item -Path $DestinationImagePath)
        }
        #=================================================
    }
    
    end {
        #=================================================
        Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
        #=================================================
    }
}