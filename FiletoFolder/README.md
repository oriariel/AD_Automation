Here is a clean `README.md` version:

````markdown
# Folder Copy Automation Script

A PowerShell script that copies folders from one location to another based on folder names listed in a CSV file.

This script is useful for automating repetitive folder-copying tasks. Instead of manually searching for each folder, the user provides a CSV file containing folder names, and the script searches for those folders inside a source directory and copies them to a destination directory.

## What the Script Does

The script:

1. Asks the user to enter the path to a CSV file.
2. Asks the user to enter the source folder path.
3. Asks the user to enter the destination folder path.
4. Reads folder names from the CSV file.
5. Searches recursively for each folder inside the source path.
6. Copies each folder that is found to the destination path.
7. Prints a message for each folder, indicating whether it was copied or not found.

## Why Paths Are Entered Manually

The script does not contain hardcoded source or destination paths.

This makes the script safer to upload to GitHub because private paths, company network paths, server names, or sensitive internal folder structures are not exposed in the code.

The user provides the relevant paths only when running the script.

## CSV File Format

The CSV file must contain a column named:

```text
FolderName
````

Example CSV file:

```csv
FolderName
Folder_A
Folder_B
Folder_C
```

Each row should contain the exact name of a folder to search for.

## How to Use

1. Open PowerShell.

2. Navigate to the folder where the script is saved:

```powershell
cd path\to\your\script
```

3. Run the script:

```powershell
.\copy_folders_from_csv.ps1
```

4. When prompted, enter the full path to the CSV file:

```text
Enter the path to the CSV file: C:\Users\YourName\Documents\folders.csv
```

5. Enter the source folder path:

```text
Enter the source folder path: C:\Path\To\SourceFolder
```

Or, for a shared network folder:

```text
Enter the source folder path: \\ServerName\SharedFolderA
```

6. Enter the destination folder path:

```text
Enter the destination folder path: C:\Path\To\DestinationFolder
```

Or, for a shared network folder:

```text
Enter the destination folder path: \\ServerName\SharedFolderB
```

The script will then search for each folder from the CSV file and copy the folders that are found.

## Example Output

If a folder is found and copied:

```text
Folder 'Folder_A' has been copied to 'C:\Path\To\DestinationFolder\Folder_A'.
```

If a folder is not found:

```text
Folder 'Folder_B' not found in 'C:\Path\To\SourceFolder'.
```

## Requirements

* Windows operating system
* PowerShell
* A CSV file with a `FolderName` column
* Permission to access the source folder
* Permission to write to the destination folder

## Important Notes

* The script searches recursively inside the source folder.
* Folder names in the CSV file must match the actual folder names exactly.
* The script uses `Copy-Item` with the `-Force` flag, so existing files in the destination may be overwritten.
* If multiple folders with the same name exist inside the source path, the script may find more than one match.
* Private company paths should not be committed to GitHub.

## Script Logic

The script receives three inputs from the user:

```powershell
$csvFilePath = Read-Host "Enter the path to the CSV file"
$searchPath = Read-Host "Enter the source folder path"
$destinationPath = Read-Host "Enter the destination folder path"
```

It then imports the CSV file:

```powershell
$folderNames = Import-Csv -Path $csvFilePath
```

For each folder name in the CSV file, the script searches inside the source path:

```powershell
Get-ChildItem -Path $searchPath -Recurse -Directory
```

If the folder is found, it is copied to the destination path.

## Possible Improvements

Future improvements could include:

* Creating a log file for copied and missing folders
* Validating that the CSV file exists before running
* Validating that the CSV contains a `FolderName` column
* Checking whether the source and destination paths exist
* Handling duplicate folder names more carefully
* Asking the user before overwriting existing folders
* Adding error messages for folders that could not be copied

## Suggested Repository Name

```text
folder-copy-automation-powershell
```

## Suggested Script File Name

```text
copy_folders_from_csv.ps1
```

## License

This project is intended for personal, educational, or internal automation use.

```
```
