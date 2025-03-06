function Test-IsHyperVEnabled {
    <#
    .SYNOPSIS
    Tests if Microsoft Hyper-V is enabled.

    .DESCRIPTION
    Tests if Microsoft Hyper-V is enabled.

    .NOTES
    Author: David Segura
    #>
    [CmdletBinding()]
    param ()

    $FeatureName = 'Microsoft-Hyper-V-All'
    $WindowsOptionalFeature = Get-WindowsOptionalFeature -Online -FeatureName $FeatureName -ErrorAction SilentlyContinue

    if ($WindowsOptionalFeature.State -eq 'Enabled') {
        return $true
    }
    elseif ($WindowsOptionalFeature.State -eq 'Disabled') {
        return $false
    }
    else {
        return $false
    }
}