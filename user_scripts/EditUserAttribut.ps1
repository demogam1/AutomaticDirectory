<#
.SYNOPSIS
    Modify an attribute of the user and set it to a new value.

.DESCRIPTION
    This script modifies a specified attribute of an Active Directory user account.
    It accepts the account name, the attribute name to update, and the new desired value.
    The script first checks if the user exists in Active Directory, and if so,
    it updates the attribute using the Set-ADUser cmdlet.

.PARAMETER AccountName
    The name of the user account to modify.

.PARAMETER AttributeName
    The attribute name that you wish to update.

.PARAMETER DesiredValue
    The new value for the specified attribute.

.EXAMPLE
    .\EditUserAttribute.ps1 -AccountName "jdoe" -AttributeName "Department" -DesiredValue "IT"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0, HelpMessage = "Enter the account name.")]
    [string]$AccountName,

    [Parameter(Mandatory = $true, Position = 1, HelpMessage = "Enter the attribute name to modify.")]
    [string]$AttributeName,

    [Parameter(Mandatory = $true, Position = 2, HelpMessage = "Enter the new value for the attribute.")]
    [string]$DesiredValue
)

# Ensure the Active Directory module is available
if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
    Write-Error "The ActiveDirectory module is not available. Please install RSAT tools or the AD module."
    exit 1
}
Import-Module ActiveDirectory

# Check if the user exists in Active Directory
try {
    $user = Get-ADUser -Identity $AccountName -ErrorAction Stop
}
catch {
    Write-Error "User '$AccountName' was not found in Active Directory."
    exit 1
}

# Attempt to modify the user attribute
try {
    Set-ADUser -Identity $AccountName -Replace @{ $AttributeName = $DesiredValue }
    Write-Output "Successfully updated attribute '$AttributeName' to '$DesiredValue' for user '$AccountName'."
}
catch {
    Write-Error "Failed to update attribute '$AttributeName' for user '$AccountName'. Error details: $_"
    exit 1
}
