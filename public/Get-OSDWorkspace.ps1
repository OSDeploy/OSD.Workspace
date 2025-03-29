function Get-OSDWorkspace {
    <#
    .SYNOPSIS
        Displays information about the OSD.Workspace PowerShell Module.

    .DESCRIPTION
        Displays information about the OSD.Workspace PowerShell Module including upcoming events and links to resources.
        This will also initialize the OSDWorkspace module and display the version of various components.

    .NOTES
        David Segura
    #>
    [CmdletBinding()]
    param ()
    #=================================================
    $Error.Clear()
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
    $ModuleName = $($MyInvocation.MyCommand.Module.Name)
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] ModuleName: $ModuleName"
    $ModuleBase = $($MyInvocation.MyCommand.Module.ModuleBase)
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] ModuleBase: $ModuleBase"
    $ModuleVersion = $($MyInvocation.MyCommand.Module.Version)
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] ModuleVersion: $ModuleVersion"

    Initialize-OSDWorkspace
    #=================================================
    Write-Host -ForegroundColor DarkCyan 'OSDWorkspace Team'
    Write-Host -ForegroundColor DarkGray "David Segura $($OSDWorkspace.links.david)"
    Write-Host -ForegroundColor DarkGray "Michael Escamilla $($OSDWorkspace.links.michael)"
    Write-Host
    Write-Host -ForegroundColor DarkCyan 'NWSCUG: OSD 2025 Preview'
    Write-Host -ForegroundColor DarkGray "March 28 2025 $($OSDWorkspace.links.nwscug)"
    Write-Host
    Write-Host -ForegroundColor DarkCyan 'MMSMOA: OSDWorkspace and OSDCloud'
    Write-Host -ForegroundColor DarkGray "May 5-8 2025 $($OSDWorkspace.links.mmsmoa)"
    Write-Host
    Write-Host -ForegroundColor DarkCyan 'WPNinjasUK: OSDWorkspace and OSDCloud'
    Write-Host -ForegroundColor DarkGray "June 16-17 2025 $($OSDWorkspace.links.wpninjasuk)"
    Write-Host
    Write-Host -ForegroundColor DarkCyan 'WPNinjas: OSDWorkspace and OSDCloud'
    Write-Host -ForegroundColor DarkGray "September 22-25, 2025 | $($OSDWorkspace.links.wpninjasch)"
    Write-Host
    Write-Host -ForegroundColor DarkCyan 'OSDWorkspace on GitHub'
    Write-Host -ForegroundColor DarkGray $($OSDWorkspace.links.github)
    Write-Host
    Write-Host -ForegroundColor DarkCyan 'OSDWorkspace on PowerShell Gallery'
    Write-Host -ForegroundColor DarkGray $($OSDWorkspace.links.powershellgallery)
    Write-Host
    Write-Host -ForegroundColor DarkCyan 'OSDWorkspace on Discord'
    Write-Host -ForegroundColor DarkGray $($OSDWorkspace.links.discord)
    Write-Host
    Write-Host -ForegroundColor DarkCyan 'OSDWorkspace Versions'
    $RegKey = 'HKCU:\Software\OSDWorkspace'
    $RegName = 'copilot-instructions.md'
    Write-Host -ForegroundColor DarkGray "Copilot       $((Get-ItemProperty $RegKey -Name $RegName -ErrorAction Ignore).$RegName)"
    Write-Host -ForegroundColor DarkGray "dism.exe      $((Get-Command dism -ErrorAction Ignore).version.ToString())"
    Write-Host -ForegroundColor DarkGray "git.exe       $((Get-Command git.exe -ErrorAction Ignore).version.ToString())"
    $RegName = '.gitignore'
    Write-Host -ForegroundColor DarkGray "Gitignore     $((Get-ItemProperty $RegKey -Name $RegName -ErrorAction Ignore).$RegName)"
    $RegName = 'Update-OSDWorkspaceHelp'
    Write-Host -ForegroundColor DarkGray "Help          $((Get-ItemProperty $RegKey -Name $RegName -ErrorAction Ignore).$RegName)"
    $RegName = 'Initialize-OSDWorkspace'
    Write-Host -ForegroundColor DarkGray "Initialize    $((Get-ItemProperty $RegKey -Name $RegName -ErrorAction Ignore).$RegName)"
    Write-Host -ForegroundColor DarkGray "Module        $ModuleVersion"
    $RegName = 'tasks.json'
    Write-Host -ForegroundColor DarkGray "Tasks         $((Get-ItemProperty $RegKey -Name $RegName -ErrorAction Ignore).$RegName)"
    $RegName = 'OSD.code-workspace'
    Write-Host -ForegroundColor DarkGray "Workspace     $((Get-ItemProperty $RegKey -Name $RegName -ErrorAction Ignore).$RegName)"
    #=================================================
    # Read the value from the registry
    # $GetValue = (Get-ItemProperty $RegKey -Name $RegName).$RegName
    #=================================================
    $null = Get-OSDWSWinRESource -WarningAction SilentlyContinue
    $null = Get-OSDWSWinOSSource -WarningAction SilentlyContinue
    $null = Get-OSDWSWinPEBuild -WarningAction SilentlyContinue
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}