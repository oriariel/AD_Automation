Here is a polished `README.md` version:

````markdown
# Update-ADManager

A PowerShell GUI tool for bulk-reassigning direct reports from one Active Directory manager to another.

## Overview

`Update-ADManager` helps administrators transfer all direct reports from one manager to another in Active Directory.

This is useful when a manager leaves the organization, changes roles, or their team needs to be reassigned. Instead of updating each user manually in **Active Directory Users and Computers**, this tool updates the `Manager` attribute for the entire team in one step.

## Features

- Simple PowerShell GUI
- Validates that both managers exist in Active Directory
- Finds all direct reports of the old manager
- Reassigns those users to the new manager
- Displays success and error messages
- Prints progress and errors to the PowerShell console

## Requirements

- Windows 10 / Windows Server 2012 R2 or later
- PowerShell 5.1 or later
- Remote Server Administration Tools (RSAT)
- Active Directory PowerShell module
- Permissions to modify user objects in Active Directory

## Usage

Run the script by right-clicking the file and selecting:

```powershell
Run with PowerShell
````

Or run it from a PowerShell console:

```powershell
.\Update-ADManager.ps1
```

A small window will appear.

Enter the following details:

* **Old Manager** — the `SamAccountName` of the manager whose team should be reassigned
* **New Manager** — the `SamAccountName` of the manager who will take over the team

Click **Start**.

The script will then:

1. Validate that both manager accounts exist in Active Directory.
2. Find all direct reports of the old manager.
3. Update the `Manager` attribute for each direct report.
4. Display a success or error message when finished.

Progress and errors are also printed to the PowerShell console window.

## Notes

* Only direct reports are affected.
* The reassignment is one level deep and is not recursive.
* The script does not disable, delete, or move the old manager’s account.
* You should verify the changes after running the script.

You can verify the new manager’s direct reports in **Active Directory Users and Computers**, or by running:

```powershell
Get-ADUser -Filter "Manager -eq '$(Get-ADUser newmanager).DistinguishedName'" -Properties DisplayName
```

Replace `newmanager` with the relevant `SamAccountName`.

## License

MIT

```
```
