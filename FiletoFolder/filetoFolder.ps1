
# Path to the CSV file with folder names

$csvFilePath = Read-Host "Enter the path to the CSV file"

# Define the shared folder path to search

$searchPath = Read-Host "Enter the source folder path"

# Define the destination path to copy the folders

$destinationPath = Read-Host "Enter the destination folder path"

# Import the CSV file

$folderNames = Import-Csv -Path $csvFilePath

foreach ($entry in $folderNames) {

    # Assume the column is named 'FolderName'

    $folderName = $entry.FolderName

    # Search for the folder

    $folderFound = Get-ChildItem -Path $searchPath -Recurse -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq $folderName }

    if ($folderFound) {

        $sourceFolderPath = $folderFound.FullName

        $destFolderPath = Join-Path -Path $destinationPath -ChildPath $folderName

        # Copy the folder

        Copy-Item -Path $sourceFolderPath -Destination $destFolderPath -Recurse -Force

        Write-Output "Folder '$folderName' has been copied to '$destFolderPath'."

    } else {

        Write-Output "Folder '$folderName' not found in '$searchPath'."

    }

}
