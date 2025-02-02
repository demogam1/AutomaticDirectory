# PowerShell script to promote a server to a Domain Controller and create a new forest
param (
    [Parameter(Mandatory = $true)]
    [string]$DomainAddress,  # Fully Qualified Domain Name (e.g., example.local)

    [Parameter(Mandatory = $true)]
    [string]$NetbiosName     # NetBIOS name (e.g., EXAMPLE)
)

# Variables
$ForestFunctionalLevel = "Default"  # Set the desired functional level (e.g., Win2016, Win2019)
$SafeModeAdminPassword = (ConvertTo-SecureString "Toto42sh@" -AsPlainText -Force)  # Set a strong DSRM password

# Ensure script is running as Administrator
If (-Not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Please run this script as Administrator." -ForegroundColor Red
    Exit
}

# Check if AD DS role is installed
$Feature = Get-WindowsFeature -Name AD-Domain-Services
if (-not $Feature.Installed) {
    Write-Host "AD DS role is not installed. Please install it before running this script." -ForegroundColor Red
    Exit
}

# Promote the server to a Domain Controller and create a new forest
Write-Host "Promoting server to Domain Controller with Domain Address: $DomainAddress and NetBIOS Name: $NetbiosName" -ForegroundColor Yellow
Install-ADDSForest -DomainName $DomainAddress `
    -ForestMode $ForestFunctionalLevel `
    -DomainMode $ForestFunctionalLevel `
    -SafeModeAdministratorPassword $SafeModeAdminPassword `
    -DomainNetbiosName $NetbiosName `
    -Force -Verbose

# Check if promotion was successful
if ($? -eq $true) {
    Write-Host "Server successfully promoted to Domain Controller for the forest: $DomainAddress with NetBIOS Name: $NetbiosName" -ForegroundColor Green
} else {
    Write-Host "Failed to promote the server to Domain Controller. Please check the error details." -ForegroundColor Red
}
