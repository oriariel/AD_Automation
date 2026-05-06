# Update-ADManager.ps1
# GUI tool to bulk-reassign direct reports from one manager to another in Active Directory.

# Load Windows Forms assembly
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Better display for Hebrew/non-ASCII
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Import Active Directory module
Import-Module ActiveDirectory -ErrorAction Stop

# -------------------------------------------------------------------
# Get all direct reports for a given manager (by Distinguished Name)
# -------------------------------------------------------------------
function Get-DirectReportsByManagerDN {
    param([Parameter(Mandatory)][string]$ManagerDN)

    Get-ADUser -Filter "Manager -eq '$ManagerDN'" `
               -Properties DisplayName, SamAccountName, EmployeeID, Title, Department, Manager |
        Select-Object DisplayName, SamAccountName, EmployeeID, Title, Department
}

# -------------------------------------------------------------------
# Update the Manager attribute for a list of users
# -------------------------------------------------------------------
function Update-ManagerForUsers {
    param(
        [Parameter(Mandatory)][string[]]$UserList,
        [Parameter(Mandatory)][string]$NewManagerDN,
        [Parameter(Mandatory)][string]$NewManagerSamAccountName,
        [bool]$UseConfirm = $false,
        [bool]$UseWhatIf  = $false
    )

    foreach ($sam in $UserList) {
        try {
            $user = Get-ADUser -Identity $sam -Properties Manager
            if (-not $user) {
                Write-Host "User not found: $sam" -ForegroundColor Red
                continue
            }

            $cmd = @{ Identity = $sam; Manager = $NewManagerDN }
            if ($UseWhatIf)  { $cmd.WhatIf   = $true }
            if ($UseConfirm) { $cmd.Confirm  = $true }

            Set-ADUser @cmd

            $action = if ($UseWhatIf) { "Would update" } else { "Updated" }
            Write-Host "$action manager for ${sam} ($($user.DisplayName)) to $NewManagerSamAccountName" -ForegroundColor Green

        } catch {
            Write-Host "Failed to update ${sam}: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

# -------------------------------------------------------------------
# Build the GUI form
# -------------------------------------------------------------------
$form = New-Object System.Windows.Forms.Form
$form.Text          = "Update Manager for Users"
$form.Size          = New-Object System.Drawing.Size(400, 200)
$form.StartPosition = "CenterScreen"

# Old Manager label + textbox
$labelOld          = New-Object System.Windows.Forms.Label
$labelOld.Text     = "Old Manager (SamAccountName):"
$labelOld.Location = New-Object System.Drawing.Point(10, 20)
$labelOld.Size     = New-Object System.Drawing.Size(200, 20)
$form.Controls.Add($labelOld)

$textBoxOld          = New-Object System.Windows.Forms.TextBox
$textBoxOld.Location = New-Object System.Drawing.Point(10, 40)
$textBoxOld.Size     = New-Object System.Drawing.Size(360, 20)
$form.Controls.Add($textBoxOld)

# New Manager label + textbox
$labelNew          = New-Object System.Windows.Forms.Label
$labelNew.Text     = "New Manager (SamAccountName):"
$labelNew.Location = New-Object System.Drawing.Point(10, 70)
$labelNew.Size     = New-Object System.Drawing.Size(200, 20)
$form.Controls.Add($labelNew)

$textBoxNew          = New-Object System.Windows.Forms.TextBox
$textBoxNew.Location = New-Object System.Drawing.Point(10, 90)
$textBoxNew.Size     = New-Object System.Drawing.Size(360, 20)
$form.Controls.Add($textBoxNew)

# Start button
$buttonStart          = New-Object System.Windows.Forms.Button
$buttonStart.Text     = "Start"
$buttonStart.Location = New-Object System.Drawing.Point(150, 120)
$buttonStart.Size     = New-Object System.Drawing.Size(100, 30)

$buttonStart.Add_Click({
    $OldManagerSamAccountName = $textBoxOld.Text.Trim()
    $NewManagerSamAccountName = $textBoxNew.Text.Trim()

    if (-not $OldManagerSamAccountName -or -not $NewManagerSamAccountName) {
        [System.Windows.Forms.MessageBox]::Show(
            "Please fill in both Old Manager and New Manager fields.",
            "Error",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }

    try {
        # Validate old manager
        $oldManager = Get-ADUser -Filter "SamAccountName -eq '$OldManagerSamAccountName'" -Properties DistinguishedName
        if (-not $oldManager) {
            [System.Windows.Forms.MessageBox]::Show(
                "Old manager not found: $OldManagerSamAccountName", "Error",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Error)
            return
        }

        # Validate new manager
        $newManager = Get-ADUser -Filter "SamAccountName -eq '$NewManagerSamAccountName'" -Properties DistinguishedName
        if (-not $newManager) {
            [System.Windows.Forms.MessageBox]::Show(
                "New manager not found: $NewManagerSamAccountName", "Error",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Error)
            return
        }

        # Fetch direct reports of the old manager
        $directs      = Get-DirectReportsByManagerDN -ManagerDN $oldManager.DistinguishedName
        $usersToUpdate = $directs | Select-Object -ExpandProperty SamAccountName

        if (-not $usersToUpdate -or $usersToUpdate.Count -eq 0) {
            [System.Windows.Forms.MessageBox]::Show(
                "No direct reports found for $OldManagerSamAccountName.", "Info",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Information)
            return
        }

        Write-Host "Updating manager for $($usersToUpdate.Count) user(s) from $OldManagerSamAccountName to $NewManagerSamAccountName..." -ForegroundColor Cyan

        Update-ManagerForUsers `
            -UserList                  $usersToUpdate `
            -NewManagerDN              $newManager.DistinguishedName `
            -NewManagerSamAccountName  $NewManagerSamAccountName

        Write-Host "Update complete. Verify changes in AD Users and Computers." -ForegroundColor Green
        [System.Windows.Forms.MessageBox]::Show(
            "Process completed successfully!",
            "Success",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information)

    } catch {
        Write-Host "An error occurred: $($_.Exception.Message)" -ForegroundColor Red
        [System.Windows.Forms.MessageBox]::Show(
            "An error occurred: $($_.Exception.Message)", "Error",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error)
    }
})

$form.Controls.Add($buttonStart)

# Show the form
[void]$form.ShowDialog()
