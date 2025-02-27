<#
.SYNOPSIS
    Reset the password of the desired user.

.DESCRIPTION
    This script resets the password of a local user account.
    It takes the account name as a parameter, checks if the account exists,
    prompts for a new password and confirmation, and then resets the password.

.PARAMETER AccountName
    The name of the user account whose password you wish to reset.

.EXAMPLE
    .\ResetUserPassword.ps1 -AccountName "JohnDoe"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0, HelpMessage = "Enter the account name.")]
    [string]$AccountName
)

# Check if the local user account exists
try {
    $user = Get-LocalUser -Name $AccountName -ErrorAction Stop
}
catch {
    Write-Error "User '$AccountName' does not exist on this system."
    exit 1
}

# Prompt for the new password and confirmation
$newPassword = Read-Host -Prompt "Enter new password for $AccountName" -AsSecureString
$confirmPassword = Read-Host -Prompt "Confirm new password for $AccountName" -AsSecureString

# Convert secure strings to plain text for comparison (be cautious with this approach)
$ptrNew = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($newPassword)
$plainNew = [Runtime.InteropServices.Marshal]::PtrToStringAuto($ptrNew)
[Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptrNew)

$ptrConfirm = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($confirmPassword)
$plainConfirm = [Runtime.InteropServices.Marshal]::PtrToStringAuto($ptrConfirm)
[Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptrConfirm)

if ($plainNew -ne $plainConfirm) {
    Write-Error "The passwords do not match. Exiting."
    exit 1
}

# Reset the user's password
try {
    Set-LocalUser -Name $AccountName -Password $newPassword
    Write-Output "Password for user '$AccountName' has been reset successfully."
}
catch {
    Write-Error "Failed to reset the password for user '$AccountName'. Error details: $_"
}
