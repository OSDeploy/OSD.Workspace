# OSDWorkspace BootDriver Repos


## Add a BootDriver Repository to the OSDWorkspace User Store

```powershell
PS C:\> Import-OSDWorkspaceGitRepository -Url https://github.com/OSDeploy/BootDriver-HP.git -Type BootDriver -Store User
Cloning into 'C:\Users\DavidSegura\AppData\Local\OSDFramework\BootDriver-Repos\BootDriver-HP'...
POST git-upload-pack (185 bytes)
POST git-upload-pack (239 bytes)
remote: Enumerating objects: 928, done.
remote: Counting objects: 100% (928/928), done.
remote: Compressing objects: 100% (468/468), done.
remote: Total 928 (delta 457), reused 928 (delta 457), pack-reused 0 (from 0)
Receiving objects: 100% (928/928), 34.65 MiB | 15.46 MiB/s, done.
Resolving deltas: 100% (457/457), done.
Updating files: 100% (772/772), done.
POST git-upload-pack (426 bytes)
POST git-upload-pack (282 bytes)
remote: Total 0 (delta 0), reused 0 (delta 0), pack-reused 0 (from 0)
From https://github.com/OSDeploy/BootDriver-HP
 = [up to date]      master     -> origin/master
```

## Add a BootDriver Repository to the OSDWorkspace AllUsers Store

```powershell
PS C:\> Import-OSDWorkspaceGitRepository -Url https://github.com/OSDeploy/BootDriver-Generic.git -Type BootDriver -Store AllUsers
Cloning into 'C:\ProgramData\OSDFramework\BootDriver-Repos\BootDriver-Generic'...
POST git-upload-pack (185 bytes)
POST git-upload-pack (239 bytes)
remote: Enumerating objects: 507, done.
remote: Counting objects: 100% (507/507), done.
remote: Compressing objects: 100% (267/267), done.
remote: Total 507 (delta 228), reused 507 (delta 228), pack-reused 0 (from 0)
Receiving objects: 100% (507/507), 127.42 MiB | 24.26 MiB/s, done.
Resolving deltas: 100% (228/228), done.
Updating files: 100% (421/421), done.
POST git-upload-pack (426 bytes)
POST git-upload-pack (282 bytes)
remote: Total 0 (delta 0), reused 0 (delta 0), pack-reused 0 (from 0)
From https://github.com/OSDeploy/BootDriver-Generic
 = [up to date]      master     -> origin/master
```

## Repository may already exist

```powershell
PS C:\> Import-OSDWorkspaceGitRepository -Url https://github.com/OSDeploy/BootDriver-HP.git -Type BootDriver -Store User
WARNING: [11:30:56] Import-OSDWorkspaceGitRepository Destination repository already exists
WARNING: [11:30:56] Import-OSDWorkspaceGitRepository Use the Update-OSDFrameworkRepository cmdlet to update this repository
```
