<#
.SYNOPSIS
    Retrieve every user's information from the server.

.DESCRIPTION
    This script retrieves information for users from Active Directory.
    It retrieves the specified attribute for every user whose account name matches the provided value.
    Use "*" or leave AccountName empty to retrieve all users.

.PARAMETER AccountName
    The account name filter. If provided, only users with a SamAccountName matching the pattern will be retrieved.
    Use "*" or an empty string to retrieve all users.

.PARAMETER Filter
    The attribute to retrieve for each user (e.g., "Mail", "Department", "Title", etc.).

.EXAMPLE
    PS C:\> .\ReadDataBaseInformation.ps1 -AccountName "jdoe" -Filter "Mail"
    Retrieves the "Mail" attribute for users whose account name contains "jdoe".

.EXAMPLE
    PS C:\> .\ReadDataBaseInformation.ps1 -AccountName "*" -Filter "Department"
    Retrieves the "Department" attribute for all users.
#>

param(
    [string]$AccountName = "*",
    [Parameter(Mandatory = $true)]
    [string]$Filter
)

try {
    # Ensure the ActiveDirectory module is loaded
    if (-not (Get-Module -Name ActiveDirectory)) {
        Import-Module ActiveDirectory -ErrorAction Stop
    }

    # Determine the search criteria for users
    if ($AccountName -eq "*" -or [string]::IsNullOrEmpty($AccountName)) {
        # Retrieve all users
        $users = Get-ADUser -Filter * -Properties $Filter -ErrorAction Stop
    }
    else {
        # Use a wildcard search for the account name
        $filterQuery = "SamAccountName -like '*$AccountName*'"
        $users = Get-ADUser -Filter $filterQuery -Properties $Filter -ErrorAction Stop
    }

    if (-not $users) {
        Write-Host "No users found matching the criteria."
        exit 0
    }

    # Output each user's Name and the specified attribute
    $users | ForEach-Object {
        $attrValue = $_.PSObject.Properties[$Filter].Value
        [PSCustomObject]@{
            Name      = $_.Name
            Attribute = $attrValue
        }
    }
}
catch {
    Write-Error "An error occurred while retrieving user information: $_"
    exit 1
}
