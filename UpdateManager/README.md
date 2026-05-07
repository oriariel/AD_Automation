Update-ADManager
A PowerShell GUI tool to bulk-reassign direct reports from one Active Directory manager to another.
What it does
When a manager leaves or changes roles, you can use this tool to transfer their entire team to a new manager in one step — no need to update each user individually in AD Users and Computers.
Requirements
•	Windows (Windows 10 / Windows Server 2012 R2 or later)
•	PowerShell 5.1+
•	Remote Server Administration Tools (RSAT) — specifically the Active Directory module
•	Permissions to modify user objects in Active Directory
Usage
1.	Right-click Update-ADManager.ps1 and choose Run with PowerShell, or run it from a PowerShell console:
.\Update-ADManager.ps1
2.	A small window will appear. Enter:
o	Old Manager — the SamAccountName (login name) of the manager whose team you are reassigning
o	New Manager — the SamAccountName of the manager who will take over the team
3.	Click Start. The script will:
o	Validate both accounts exist in AD
o	Find all direct reports of the old manager
o	Update the Manager attribute for each of those users to the new manager
o	Show a success or error message when done
Progress and any errors are also printed to the PowerShell console window.
Notes
•	Only direct reports are affected (one level deep — not recursive).
•	The script does not disable or move the old manager's account.
•	Changes can be verified afterwards in Active Directory Users and Computers or with:
Get-ADUser -Filter "Manager -eq '$(Get-ADUser newmanager).DistinguishedName'" -Properties DisplayName
License
MIT

