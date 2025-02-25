param (
    [Parameter(Mandatory = $true)]
    [string]$Path,
    [Parameter(Mandatory = $true)]
    [string]$Delimiter
)

# Check if the file exists
if (-not (Test-Path -Path $Path)) {
    Write-Host "Error: The specified file does not exist: $Path"
    exit 1
}

# Try to import the CSV file
try {
    $data = Import-Csv -Path $Path -Delimiter $Delimiter

    # Display data preview
    Write-Host "Successfully loaded the database from: $Path"
    Write-Host "Preview of loaded data:"
    $data | Format-Table -AutoSize -Wrap

    # Store the data in a global variable for further use
    $Global:LoadedData = $data
} catch {
    Write-Host "Error loading the database: $_"
    exit 1
}
