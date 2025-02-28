function Update-EnvironmentVariables {
    [CmdletBinding()]
    param ()
    $RegPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment',
    'HKCU:\Environment'

    $RegPath | ForEach-Object {   
        $k = Get-Item $_
        $k.GetValueNames() | ForEach-Object {
            $name = $_
            $value = $k.GetValue($_)
            Set-Item -Path Env:\$name -Value $value
        }
    }
}