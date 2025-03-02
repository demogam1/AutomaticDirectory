param(
    [Parameter(Mandatory = $true)]
    [string]$GroupName,

    [Parameter(Mandatory = $true)]
    [string]$Attribute,

    [Parameter(Mandatory = $true)]
    [string]$NewValue
)

try {
    # Ensure the ActiveDirectory module is loaded
    if (-not (Get-Module -Name ActiveDirectory)) {
        Import-Module ActiveDirectory -ErrorAction Stop
    }

    # Retrieve the group object from Active Directory
    $group = Get-ADGroup -Identity $GroupName -ErrorAction Stop
    if (-not $group) {
        Write-Error "Group '$GroupName' not found."
        exit 1
    }

    # Update the specified attribute with the new value
    Set-ADGroup -Identity $GroupName -Replace @{ $Attribute = $NewValue } -ErrorAction Stop

    Write-Output "Group '$GroupName' updated: Attribute '$Attribute' has been set to '$NewValue'."
}
catch {
    Write-Error "An error occurred while modifying the group: $_"
    exit 1
}
