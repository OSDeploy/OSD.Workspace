function Open-OSDWorkspace {
    <#
    .SYNOPSIS
        Opens the OSDWorkspace in VS Code or the specified Applications.

    .DESCRIPTION
        Opens the OSDWorkspace in VS Code or the specified Applications.

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
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
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
            Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Visual Studio Code is not installed.  WinGet install:"
            Write-Host 'winget install -e --id Microsoft.VisualStudioCode'
            Break
        }
        Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Opening OSDWorkspace in Visual Studio Code"
        #Start-Process @Params -ErrorAction SilentlyContinue
        Start-Process -FilePath "$env:LocalAppData\Programs\Microsoft VS Code\Code.exe" -WindowStyle Maximized -Verb RunAs -ArgumentList "$(Get-OSDWorkspacePath)"
    }

    if ($Application -eq 'Explorer') {
        Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Opening OSDWorkspace in Windows Explorer"
        explorer.exe $(Get-OSDWorkspacePath)
    }

    if ($Application -eq 'Terminal') {
        Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Opening OSDWorkspace in Windows Terminal"
        Start-Process -FilePath wt.exe -Verb RunAs -ArgumentList "-d $(Get-OSDWorkspacePath)"
    }
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}