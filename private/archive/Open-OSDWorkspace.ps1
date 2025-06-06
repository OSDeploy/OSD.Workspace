function Open-OSDWorkspace {
    <#
    .SYNOPSIS
        Opens the OSDWorkspace in VS Code or the specified Application.

    .DESCRIPTION
        Opens the OSDWorkspace in VS Code or the specified Applications.

    .PARAMETER Application
        The application to open the OSDWorkspace in. Valid values are 'code', 'Explorer', and 'Terminal'. Default is 'code'.

    .INPUTS
        None.

        You cannot pipe input to this cmdlet.

    .OUTPUTS
        None.

        This function does not return any output.

    .EXAMPLE
        Open-OSDWorkspace
        Opens the OSDWorkspace in Visual Studio Code.

    .EXAMPLE
        Open-OSDWorkspace -Application Explorer
        Opens the OSDWorkspace in Windows Explorer.

    .EXAMPLE    
        Open-OSDWorkspace -Application Terminal
        Opens the OSDWorkspace in Windows Terminal.

    .LINK
        https://github.com/OSDeploy/OSD.Workspace/blob/main/docs/Open-OSDWorkspace.md

    .NOTES
        David Segura
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [ValidateSet('code', 'Explorer', 'Terminal')]
        [System.String]
        $Application = 'code'
    )
    #=================================================
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Start"
    $Error.Clear()
    #=================================================
    $Params = @{
        FilePath         = $Application
        Verb             = 'RunAs'
        WindowStyle      = 'Maximized'
        WorkingDirectory = $(Get-OSDWorkspacePath)
        ArgumentList     = "$(Get-OSDWorkspacePath)"
    }
    #=================================================
    #region Visual Studio Code
    if ($Application -eq 'code') {
        #TODO add support for Machine-Wide installation of code
        if (Test-Path -Path "$env:LocalAppData\Programs\Microsoft VS Code\Code.exe") {
            $Params.FilePath = "$env:LocalAppData\Programs\Microsoft VS Code\Code.exe"
        }
        else {
            Write-Warning "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Visual Studio Code is not installed.  WinGet install:"
            Write-Host 'winget install -e --id Microsoft.VisualStudioCode'
            Break
        }
        Write-Host -ForegroundColor DarkCyan "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Opening OSDWorkspace in Visual Studio Code"
        #Start-Process @Params -ErrorAction SilentlyContinue
        Start-Process -FilePath "$env:LocalAppData\Programs\Microsoft VS Code\Code.exe" -WindowStyle Maximized -Verb RunAs -ArgumentList "$(Get-OSDWorkspacePath)"
    }

    if ($Application -eq 'Explorer') {
        Write-Host -ForegroundColor DarkCyan "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Opening OSDWorkspace in Windows Explorer"
        explorer.exe $(Get-OSDWorkspacePath)
    }

    if ($Application -eq 'Terminal') {
        Write-Host -ForegroundColor DarkCyan "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Opening OSDWorkspace in Windows Terminal"
        Start-Process -FilePath wt.exe -Verb RunAs -ArgumentList "-d $(Get-OSDWorkspacePath)"
    }
    #=================================================
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}