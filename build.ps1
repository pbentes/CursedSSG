# Define the output directory
$directoryPath = ".\out\"

if ((Test-Path $directoryPath)) {
    Remove-Item -Path $directoryPath -Recurse -Force
}

# Create the output directory if it doesn't exist
if (-not (Test-Path $directoryPath)) {
    New-Item -ItemType Directory -Path $directoryPath
}

Copy-Item -Path "./js/" -Destination $directoryPath -Recurse
Copy-Item -Path "./css/" -Destination $directoryPath -Recurse
Copy-Item -Path "./static/*" -Destination $directoryPath -Recurse

# Get all HTML files not in the out directory
$htmlFiles = Get-ChildItem -Path . -Recurse -Filter *.html | Where-Object { $_.FullName -notmatch [regex]::Escape($directoryPath) }

foreach ($file in $htmlFiles) {
    $contentPath = $file.FullName -replace ([regex]::Escape((Get-Location).Path) + [regex]::Escape("\")), ""

    Write-Output $contentPath

    # Extract the directory part of the content path
    $contentDirectoryPath = Split-Path -Path $contentPath

    # Remove leading .\ from the content directory path and combine with the out directory
    $relativeContentDirectoryPath = $contentDirectoryPath -replace "^\.\\", ""
    $outputContentDirectoryPath = Join-Path -Path $directoryPath -ChildPath $relativeContentDirectoryPath

    # Ensure the combined directory structure exists
    if (-not (Test-Path $outputContentDirectoryPath)) {
        New-Item -ItemType Directory -Path $outputContentDirectoryPath -Force
    }

    # Extract the file name and combine with the output directory path
    $contentFileName = Split-Path -Path $contentPath -Leaf
    $outputFilePath = Join-Path -Path $outputContentDirectoryPath -ChildPath $contentFileName

    # Preprocess the HTML content and write to the output file
    cl /P /EP /Fi"$outputFilePath" /D FILE="$contentPath" $contentPath ./layout.html
}
