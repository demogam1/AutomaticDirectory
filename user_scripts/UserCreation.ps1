param (
    [Parameter(Mandatory = $true)]
    [string]$AccountName,

    [Parameter(Mandatory = $true)]
    [string]$OrganizationalUnit,

    [Parameter(Mandatory = $true)]
    [string]$DesiredGroup
)

# Define domain and default password (hashed for security)
$DomainName = "domolia-ad.corp"

# Generate Name and Email
$NameParts = $AccountName -split "\s"
$FirstName = $NameParts[0]
$LastName = $NameParts[-1]
$Email = "$FirstName.$LastName@$DomainName"

# Securely store the default password
$DefaultPassword = Read-Host -Prompt "Enter temporary password" -AsSecureString

# Construct the UserPrincipalName (UPN)
$UserPrincipalName = $Email.ToLower()

# Check if the user already exists
if (Get-ADUser -Filter {UserPrincipalName -eq $UserPrincipalName}) {
    Write-Host "User $UserPrincipalName already exists. Aborting." -ForegroundColor Red
    exit 1
}

# Create the new AD user
New-ADUser -SamAccountName $AccountName `
           -UserPrincipalName $UserPrincipalName `
           -Name "$FirstName $LastName" `
           -GivenName $FirstName `
           -Surname $LastName `
           -EmailAddress $Email `
           -Path $OrganizationalUnit `
           -AccountPassword $DefaultPassword `
           -Enabled $true `
           -ChangePasswordAtLogon $true `
           -PassThru

Write-Host "User $UserPrincipalName has been created in $OrganizationalUnit" -ForegroundColor Green

# Add the user to the specified group
try {
    Add-ADGroupMember -Identity $DesiredGroup -Members $AccountName
    Write-Host "User $UserPrincipalName added to group $DesiredGroup" -ForegroundColor Cyan
} catch {
    Write-Host "Failed to add $UserPrincipalName to group $DesiredGroup" -ForegroundColor Red
}

