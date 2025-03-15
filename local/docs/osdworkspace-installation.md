## OSD.Workspace PowerShell Module Installation

Install the OSD.Workspace PowerShell Module from the PowerShell Gallery.

```powershell
Install-Module -Name OSDWorkspace -Scope CurrentUser -SkipPublisherCheck
```

## OSDWorkspace First Run
After installing the OSD.Workspace PowerShell Module, you should relaunch PowerShell to load the module into your session. Then run the following command

```powershell
Open-OSDWorkspace
```
### Admin Rights
Admin Rights are needed when working with Windows Images and the Windows ADK. Make sure you open PowerShell as Administrator or you will get a warning message:

run the following PowerShell snippet to reload the PowerShell environment:

```powershell
$RegPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment', 'HKCU:\Environment'
$RegPath | ForEach-Object {   
    $k = Get-Item $_
    $k.GetValueNames() | ForEach-Object {
        $name = $_
        $value = $k.GetValue($_)
        Set-Item -Path Env:\$name -Value $value
    }
}
```

## Starting OSDWorkspace

If this is your first time using OSDWorkspace, it is recommended you use the following command to get started. The -Verbose parameter can be used to see the steps used in any OSDWorkspace function.
