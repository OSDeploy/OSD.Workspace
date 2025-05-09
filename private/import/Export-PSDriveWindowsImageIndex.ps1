function Export-PSDriveWindowsImageIndex {
    [CmdletBinding()]
    param (
        [Parameter()]
        $Path
    )

    begin {
        #=================================================
        $Error.Clear()
        Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Start"
        #=================================================
        $IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        if (-not $IsAdmin ) {
            Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] This function must be Run as Administrator"
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
            Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] foreach"

            # Set the BuildDateTime
            $BuildDateTime = $((Get-Date).ToString('yyMMdd-HHmm'))
            Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] BuildDateTime: $BuildDateTime]"

            # Set the Architecture
            $Architecture = $SourceWindowsImage.Architecture
            Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Architecture: $Architecture]"

            # Set the Destination Name
            $DestinationName = "$BuildDateTime $Architecture"
            Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] DestinationName: $DestinationName]"
            
            # Set the Destination Path
            $DestinationDirectory = Join-Path $env:Temp "$DestinationName"
            Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] DestinationDirectory: $DestinationDirectory"

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
            $ImportId | ConvertTo-Json -Depth 5 | Out-File "$DestinationCore\id.json" -Encoding utf8 -Force






            $Guid = [Guid]::NewGuid().ToString()
            $FileName = (Split-Path $SourceWindowsImage.ImagePath -Leaf).ToLower()

            $DestinationPath = $env:TEMP + "\$Guid"
            Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] DestinationPath: $DestinationPath"

            $DestinationImagePath = "$DestinationPath\$FileName"
            Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] DestinationImagePath: $DestinationImagePath"

            try {
                # Export the Operating System install.wim
                $NewItem = New-Item -Path $DestinationPath -ItemType Directory -Force -ErrorAction Stop
                Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Export WindowsImage to $DestinationImagePath"
                $ExportWindowsImage = Export-WindowsImage -SourceImagePath $SourceWindowsImage.ImagePath -SourceIndex $SourceWindowsImage.ImageIndex -DestinationImagePath $DestinationImagePath -ErrorAction Stop

                # Export the Operating System information
                $Image = Get-WindowsImage -ImagePath $DestinationImagePath -Index 1

                Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Export $DestinationPath\winos-windowsimage.xml"
                $Image | Export-Clixml -Path "$DestinationPath\winos-windowsimage.xml"
                
                Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Export $DestinationPath\winos-windowsimage.json"
                $Image | ConvertTo-Json -Depth 5 | Out-File "$DestinationPath\winos-windowsimage.json" -Encoding utf8 -Force
            }
            catch {
                throw $_
            }

            
            Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Output: Get-Item -Path $DestinationImagePath"
            $(Get-Item -Path $DestinationImagePath)
        }
        #=================================================
    }
    
    end {
        #=================================================
        Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] End"
        #=================================================
    }
}