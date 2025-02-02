# This script uses kramdoc to convert MarkDown to AsciiDoc
# Reference: https://matthewsetter.com/technical-documentation/asciidoc/convert-markdown-to-asciidoc-with-kramdoc/
# Github: https://github.com/asciidoctor/kramdown-asciidoc

# Request the path to the MarkDown files
$InputFolder = Read-Host "Enter the base folder containing all MarkDown files (ex. 'c:\Users\me\Notes')"

# Generate AsciiDoc files
$InputFiles = @()
$InputFiles = Get-ChildItem -Path "$($InputFolder)" -Recurse -Include *.md -File
foreach ($InputFile in $InputFiles) {
  if ($InputFile.FullName -notmatch "\\_OLD\\") {
    # Determine output file name
    $outfile = $InputFile.FullName -replace '.md$','.adoc'
    # Determine central image location
    $imagesdircomponents = (($InputFile.FullName -replace [System.Text.RegularExpressions.Regex]::Escape($InputFolder),"") -replace "^\\","").Split('\')
    $imagesdir = ""
    foreach ($imagesdircomponent in $imagesdircomponents) {
      $imagesdir = "../$imagesdir"
    }
    $imagesdir = "$($imagesdir)resources/media"
    # Convert files
    Write-Host "Converting '$($InputFile.FullName)'"
    kramdoc --format=GFM --output="$($outfile)" --wrap=ventilate --auto-id-prefix=_ --auto-id-separator=_ --auto-ids --imagesdir=media -a imagesdir=$imagesdir "$($InputFile.FullName)"
    Write-Host "Done!"
  }
}

# Move media to central location
$MediaFolder = Read-Host "Enter the folder containing all Media files (ex. 'c:\Users\me\Notes\resources\media')"
$MediaInputFiles = @()
$MediaInputFiles = Get-ChildItem -Path "$($InputFolder)" -Recurse -Exclude *.md,*.adoc -File
foreach ($MediaInputFile in $MediaInputFiles) {
  if ($MediaInputFile.FullName -notmatch "\\_OLD\\") {
    if ($MediaInputFile.FullName -match "\\media\\") {
      try {
        Write-Host "Moving file '$($MediaInputFile.FullName)' to '$($MediaFolder.Trim('\'))\$($MediaInputFile.Name)'"
        Move-Item -Path "$($MediaInputFile.FullName)" -Destination "$($MediaFolder.Trim('\'))\$($MediaInputFile.Name)"
        Write-Host "Done!"
      }
      catch {
        Write-Host "Error moving file '$($MediaInputFile.FullName)': $($Error[0].ToString())"
      }
    }
  }
}

# Check to make sure the PGP key passphrase is in the agents' memory
Write-Host "Please test your resulting AsciiDoc files, especially the ones with images"
$continue = Read-Host "WARNING: Are you sure you wish to clean-up? (Y/N)"
if ($continue -notmatch "[y]") {
  Write-Verbose "Aborted by user input, exiting..."
  exit
}

# Remove legacy Markdown Files
$ToBeDeletedInputFiles = @()
$ToBeDeletedInputFiles = Get-ChildItem -Path "$($InputFolder)" -Recurse -Include *.md -File
foreach ($ToBeDeletedInputFile in $ToBeDeletedInputFiles) {
  if ($ToBeDeletedInputFile.FullName -notmatch "\\_OLD\\") {
    Write-Host "Removing '$($ToBeDeletedInputFile.FullName)'"
    Remove-Item -Path "$($ToBeDeletedInputFile.FullName)" -Force
    Write-Host "Done!"
  }
}

# Remove media folders
$MediaFolders = @()
$MediaFolders = Get-ChildItem -Path "$($InputFolder)" -Recurse -Include media -Directory
foreach ($MediaFolder in $MediaFolders) {
  if ($MediaFolder.FullName -notmatch "\\_OLD\\") {
    Write-Host "Removing '$($MediaFolder.FullName)'"
    Remove-Item -Path "$($MediaFolder.FullName)" -Force
    Write-Host "Done!"
  }
}
