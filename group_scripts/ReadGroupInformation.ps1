[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$GroupName,

    [Parameter(Mandatory = $false)]
    [string]$PropertyName
)

# If the PropertyName parameter was not provided, prompt the user.
if (-not $PropertyName) {
    $PropertyName = Read-Host "Enter property name (leave blank to retrieve all properties)"
}

# Attempt to retrieve the group information with all properties.
try {
    $group = Get-ADGroup -Identity $GroupName -Properties *
}
catch {
    Write-Error "Unable to retrieve group information. Ensure the group '$GroupName' exists and the ActiveDirectory module is installed."
    exit 1
}

# Display output based on whether a property name was provided.
if ([string]::IsNullOrEmpty($PropertyName)) {
    # No property specified; display all properties.
    $group
}
else {
    if ($group.PSObject.Properties.Name -contains $PropertyName) {
        $group | Select-Object $PropertyName
    }
    else {
        Write-Warning "Property '$PropertyName' does not exist for group '$GroupName'. Displaying all available properties."
        $group
    }
}
