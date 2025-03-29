# Main Instructions

Workspace structure is defined in the file C:\OSDWorkspace\OSD.code-workspace

Details about Windows Sources are in ${workspaceFolder}\source\windows-os\index.json
Details about WinRE Sources are in ${workspaceFolder}\source\windows-re\index.json
Details about WinPE Builds are in ${workspaceFolder}\build\windows-pe\index.json

Use Tasks as much as possible in chat. Tasks are defined in the .vscode/tasks.json file

# Coding Guidelines

## Introduction

These are VS Code coding guidelines. Please also review our [Source Code Organisation](https://github.com/microsoft/vscode/wiki/Source-Code-Organization) page.

## Indentation

We use tabs, not spaces.

## Naming Conventions

* Use PascalCase for `type` names
* Use PascalCase for `enum` values
* Use camelCase for `function` and `method` names
* Use camelCase for `property` names and `local variables`
* Use whole words in names when possible

## Types

* Do not export `types` or `functions` unless you need to share it across multiple components
* Do not introduce new `types` or `values` to the global namespace

## Comments

* When there are comments for `functions`, `interfaces`, `enums`, and `classes` use JSDoc style comments

## Strings

* Use "double quotes" for strings shown to the user that need to be externalized (localized)
* Use 'single quotes' otherwise
* All strings visible to the user need to be externalized

## Style

* Use arrow functions `=>` over anonymous function expressions
* Only surround arrow function parameters when necessary. For example, `(x) => x + x` is wrong but the following are correct:

```javascript
x => x + x
(x, y) => x + y
<T>(x: T, y: T) => x === y
```

* Always surround loop and conditional bodies with curly braces
* Open curly braces always go on the same line as whatever necessitates them
* Parenthesized constructs should have no surrounding whitespace. A single space follows commas, colons, and semicolons in those constructs. For example:

```javascript
for (let i = 0, n = str.length; i < 10; i++) {
    if (x < 10) {
        foo();
    }
}

function f(x: number, y: string): void { }
```

# OSDWorkspace
OSDWorkspace is a VS Code Workspace and is located at C:\OSDWorkspace used to build WinPE BootImages and BootMedia.
OSDWorkspace should be opened in Visual Studio Code and run on Windows 11.
OSDWorkspace on Windows Server or Windows 10 is not supported.

# OSD.Workspace PowerShell Module
OSDWorkspace is managed by PowerShell functions in the OSD.Workspace PowerShell Module.
OSD.Workspace functions are documented in C:\OSDWorkspace\docs\powershell-help\OSD.Workspace\*.md files.
OSD.Workspace functions need to be Run as Administrator.
OSD.Workspace functions should be run in Windows Terminal.

# Reference Documents
Additional PowerShell functions are documented in the functions C:\OSDWorkspace\docs\powershell-help\<ModuleName>\*.md files.
Where <ModuleName> is the name of the PowerShell Module.

# Facts
Commands are functions, and functions are commands.
Functions should be referenced whenever possible.
PowerShell functions require Windows PowerShell 5.1 or PowerShell 7.

# Best Practices
Do not reference files that do not exist in the OSDWorkspace.
Do not edit any *.md files in the OSDWorkspace as they are for reference.

# Definitions
WinPE is the abbreviation for Windows Preinstallation Environment which is used to boot a computer from a network, CD, DVD, or USB drive for the purpose of installing an operating system or performing maintenance tasks.

WinRE is the abbreviation for Windows Recovery Environment is used to repair a Windows installation when the operating system fails to boot. It also contains Wireless Network drivers to connect to a network and can be converted to a WinPE BootImage.

# Workspace Structure
Defined in the OSD.code-workspace file.
The OSD.code-workspace file is located in the C:\OSDWorkspace folder.