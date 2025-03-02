<#
.SYNOPSIS
    Retrieve user information from the server.

.DESCRIPTION
    This script retrieves information for a specified user from Active Directory.
    It allows filtering by a specific attribute.

.PARAMETER AccountName
    The account name of the user to query.

.PARAMETER Filter
    The specific attribute to retrieve for the user.

.EXAMPLE
    PS C:\> .\ReadUserInformation.ps1 -AccountName "jdoe" -Filter "Mail"
    This example retrieves the "Mail" attribute for the user "jdoe".
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$AccountName,

    [Parameter(Mandatory = $true)]
    [string]$Filter
)

try {
    # Ensure the ActiveDirectory module is loaded
    if (-not (Get-Module -Name ActiveDirectory)) {
        Import-Module ActiveDirectory -ErrorAction Stop
    }

    # Retrieve the user object including the specified attribute
    $user = Get-ADUser -Identity $AccountName -Properties $Filter -ErrorAction Stop

    if ($null -eq $user) {
        Write-Error "User '$AccountName' not found."
        exit 1
    }

    # Output the user's name and the requested attribute
    $result = [PSCustomObject]@{
        Name      = $user.Name
        Attribute = $user.$Filter
    }

    Write-Output $result
}
catch {
    Write-Error "An error occurred while retrieving user information: $_"
    exit 1
}