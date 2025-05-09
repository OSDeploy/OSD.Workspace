function Test-IsWindowsAdkInstalled {
    <#
    .SYNOPSIS
    Tests if the Windows Assessment and Deployment Kit is installed.

    .DESCRIPTION
    Tests if the Windows Assessment and Deployment Kit is installed.

    .NOTES
    Author: David Segura
    #>
    [CmdletBinding()]
    param ()

    $WindowsKitsInstallPath = Get-WindowsKitsInstallPath

    if ($WindowsKitsInstallPath) {
        Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Windows Assessment and Deployment Kit is installed"
        return $true

    }
    else {
        Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Windows Assessment and Deployment Kit is not installed"
        return $false
    }
}