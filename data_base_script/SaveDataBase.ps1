param (
    [Parameter(Mandatory = $true)]
    [string]$Path,
    [Parameter(Mandatory = $true)]
    [string]$Delimiter,
    [Parameter(Mandatory = $true)]
    [string[]]$Properties
)

# Ensure the Active Directory module is available
if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
    Write-Host "Active Directory module is not installed. Please install RSAT tools."
    exit 1
}

# Define default properties if none are provided
if ($Properties.Count -eq 0) {
    $Properties = @("Name", "SamAccountName", "DistinguishedName", "ObjectClass")
}

# Ensure Path is provided
if (-not $Path) {
    Write-Host "Please provide a valid output file path."
    exit 1
}

# Fetch Users from Active Directory
$users = Get-ADUser -Filter * -Property $Properties | Select-Object $Properties

# Fetch Groups from Active Directory
$groups = Get-ADGroup -Filter * -Property $Properties | Select-Object $Properties

# Merge Users and Groups
$data = $users + $groups

# Export to CSV
try {
    $data | Export-Csv -Path $Path -Delimiter $Delimiter -NoTypeInformation -Encoding UTF8
    Write-Host "Database successfully saved to $Path"
} catch {
    Write-Host "Failed to save database: $_"
}
