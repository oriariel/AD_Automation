Add-Type -AssemblyName System.Windows.Forms

# Create the form

$form = New-Object System.Windows.Forms.Form

$form.Text = "AD Group Processing"

$form.Size = New-Object System.Drawing.Size(400,200)

$form.StartPosition = "CenterScreen"

# Label for AD Group to add

$labelAdd = New-Object System.Windows.Forms.Label

$labelAdd.Text = "AD group to ADD:"

$labelAdd.Location = New-Object System.Drawing.Point(10,20)

$labelAdd.Size = New-Object System.Drawing.Size(150,20)

$form.Controls.Add($labelAdd)

# TextBox for AD group to add

$textBoxAdd = New-Object System.Windows.Forms.TextBox

$textBoxAdd.Location = New-Object System.Drawing.Point(170,20)

$textBoxAdd.Size = New-Object System.Drawing.Size(200,20)

$form.Controls.Add($textBoxAdd)

# Label for AD Group to remove

$labelRemove = New-Object System.Windows.Forms.Label

$labelRemove.Text = "AD group to REMOVE:"

$labelRemove.Location = New-Object System.Drawing.Point(10,60)

$labelRemove.Size = New-Object System.Drawing.Size(150,20)

$form.Controls.Add($labelRemove)

# TextBox for AD group to remove

$textBoxRemove = New-Object System.Windows.Forms.TextBox

$textBoxRemove.Location = New-Object System.Drawing.Point(170,60)

$textBoxRemove.Size = New-Object System.Drawing.Size(200,20)

$form.Controls.Add($textBoxRemove)

# Start Button

$buttonStart = New-Object System.Windows.Forms.Button

$buttonStart.Text = "Start"

$buttonStart.Location = New-Object System.Drawing.Point(150,100)

$buttonStart.Size = New-Object System.Drawing.Size(100,30)

$form.Controls.Add($buttonStart)

# Define the script block to run after clicking "Start"

$scriptBlock = {

    param($adGroupAdd, $adGroupRemove)

    # Your main script starts here, replacing the static values with the input variables

    # Hardcoded CSV file path

    $CsvFilePath = "A:\Win11\ActiveDirectoryGroup.csv"

    # Assign input values to variables

    $ADGroupToAdd = $adGroupAdd

    $ADGroupToRemove = $adGroupRemove

    # Import the ActiveDirectory module

    Import-Module ActiveDirectory -ErrorAction Stop

    # Validate the CSV file exists

    if (-not (Test-Path -Path $CsvFilePath)) {

        [System.Windows.Forms.MessageBox]::Show("Error: File '$CsvFilePath' does not exist.", "Error", 'OK', 'Error')

        return

    }

# Check file content for binary data

    $firstLine = Get-Content -Path $CsvFilePath -TotalCount 1 -ErrorAction SilentlyContinue

    if ($firstLine -and $firstLine -match '[^\x20-\x7E\t\r\n]') {

        [System.Windows.Forms.MessageBox]::Show("Warning: File appears to contain binary data. Extract it to a text file first.", "Warning", 'OK', 'Warning')

        return

    }

    # Validate the target AD group to add

    try {

        $group = Get-ADGroup -Identity $ADGroupToAdd -ErrorAction Stop

    } catch {

        [System.Windows.Forms.MessageBox]::Show("Error: AD group '$ADGroupToAdd' not found.", "Error", 'OK', 'Error')

        return

    }

    # Validate the AD group to remove

    try {

        $groupRemove = Get-ADGroup -Identity $ADGroupToRemove -ErrorAction Stop

    } catch {

        [System.Windows.Forms.MessageBox]::Show("Error: AD group '$ADGroupToRemove' not found.", "Error", 'OK', 'Error')

        return

    }

    # Read usernames from CSV

    try {

        $usernames = Get-Content -Path $CsvFilePath -ErrorAction Stop

    } catch {

        [System.Windows.Forms.MessageBox]::Show("Error reading file: $($_.Exception.Message)", "Error", 'OK', 'Error')

        return

    }

    # Loop through each username

    foreach ($username in $usernames) {

        $username = $username.Trim()

        if ([string]::IsNullOrEmpty($username)) {

            continue

        }

        try {

            $adUser = Get-ADUser -Identity $username -ErrorAction Stop

            # Check if user is already in the target group

            $groupMembers = Get-ADGroupMember -Identity $ADGroupToAdd -ErrorAction SilentlyContinue

            if ($groupMembers | Where-Object { $_.SamAccountName -eq $adUser.SamAccountName }) {

                # Already a member

            } else {

                # Add the user to the group

                Add-ADGroupMember -Identity $ADGroupToAdd -Members $adUser.SamAccountName -ErrorAction Stop -Verbose -Confirm:$false

            }

            # Remove the user from the other group

            try {

                Remove-ADGroupMember -Identity $ADGroupToRemove -Members $adUser.SamAccountName -ErrorAction Stop -Verbose -Confirm:$false

            } catch {

                if ($_.Exception -and $_.Exception.Message -match "not a member") {

                    # User not in group, ignore

                } else {

                    throw

                }

            }

        } catch {

            # Handle individual user errors silently or log as needed

        }

    }

# Send notification email via Outlook after script finishes

    try {

        $outlook = New-Object -ComObject Outlook.Application

        $mail = $outlook.CreateItem(0)

        $mail.To = "Enter email"

        $mail.CC = "Enter email for CC"

        $mail.Subject = "שדרוג עמדות Win11"

        $mail.HTMLBody = @"

        <p>Complete!</p>

       

"@

        $mail.DeferredDeliveryTime = (Get-Date)

        $mail.Send()

        $emailSent = $true

    } catch {

        $emailSent = $false

    }

    # Show completion message

    if ($emailSent) {

        [System.Windows.Forms.MessageBox]::Show("Complete! An email has been sent.", "Done", 'OK', 'Information')

    } else {

        [System.Windows.Forms.MessageBox]::Show("Complete! But failed to send email.", "Done", 'OK', 'Information')

    }

    # Clean up COM objects

    if ($mail) { [System.Runtime.Interopservices.Marshal]::ReleaseComObject($mail) | Out-Null }

    if ($outlook) { [System.Runtime.Interopservices.Marshal]::ReleaseComObject($outlook) | Out-Null }

    [System.GC]::Collect()

    [System.GC]::WaitForPendingFinalizers()

}

# Assign the button click event to run the script

$buttonStart.Add_Click({

    $form.Close()

    & $scriptBlock -adGroupAdd $textBoxAdd.Text -adGroupRemove $textBoxRemove.Text

})

# Show the form

[void]$form.ShowDialog()
