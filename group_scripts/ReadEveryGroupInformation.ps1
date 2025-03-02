[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$PropertyName
)

# Prompt user for property name if not provided on launch.
if (-not $PropertyName) {
    $PropertyName = Read-Host "Enter property name (leave blank to retrieve all properties)"
}

# Retrieve all Active Directory groups with all properties.
try {
    $groups = Get-ADGroup -Filter * -Properties *
}
catch {
    Write-Error "Failed to retrieve groups. Ensure that the ActiveDirectory module is installed and that you have sufficient permissions."
    exit 1
}

if (-not $groups) {
    Write-Warning "No groups were found in the domain."
    exit 0
}

if ([string]::IsNullOrEmpty($PropertyName)) {
    # No property specified; display all properties.
    $groups
}
else {
    # Check if the specified property exists in the group objects.
    if ($groups[0].PSObject.Properties.Name -contains $PropertyName) {
        # Avoid duplicate selection if the property is "Name".
        if ($PropertyName -eq "Name") {
            $groups | Select-Object $PropertyName
        }
        else {
            $groups | Select-Object Name, $PropertyName
        }
    }
    else {
        Write-Warning "Property '$PropertyName' does not exist for AD groups. Displaying all available properties instead."
        $groups
    }
}
