# Add an OSDWorkspace Library (submodules)

1. Select an example Repository from [OSDeploy's GitHub Repositories](https://github.com/OSDeploy?tab=repositories&q=OSDWS&type=&language=&sort=name)
2. Copy the Repository Git URL with the `.git` extension from the selected repository.
```text
https://github.com/OSDeploy/OSDWSLibrary-OSDCloud-Archive.git
```
3. Use the Git URL to import the Repository into the OSDWorkspace Library (submodules)
```powershell
Add-OSDWorkspaceRemoteLibrary -Url <RepositoryUrl>
```
4. It is recommended that you `git commit` the changes to OSDWorkspace:
https://git-scm.com/docs/git-commit

## Sample Output

```powershell
PowerShell 7.5.0
PS C:\Users\david> Add-OSDWorkspaceRemoteLibrary -Url <RepositoryUrl>
Cloning into 'C:/OSDWorkspace/submodules/OSDWSLibrary-WindowsUpdate'...
remote: Enumerating objects: 15, done.
remote: Counting objects: 100% (15/15), done.
remote: Compressing objects: 100% (8/8), done.
remote: Total 15 (delta 5), reused 15 (delta 5), pack-reused 0 (from 0)
Receiving objects: 100% (15/15), 5.15 KiB | 5.15 MiB/s, done.
Resolving deltas: 100% (5/5), done.
warning: in the working copy of '.gitmodules', LF will be replaced by CRLF the next time Git touches it
```