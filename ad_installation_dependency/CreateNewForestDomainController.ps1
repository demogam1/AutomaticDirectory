param (
    [Parameter(Mandatory = $true)]
    [string]$DomainAddress,

    [Parameter(Mandatory = $true)]
    [string]$NetbiosName
)

# Check if the script is running as Administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script must be run as an Administrator!" -ForegroundColor Red
    exit
}

# Check if Active Directory Domain Services (AD DS) is installed
if (-not (Get-WindowsFeature -Name AD-Domain-Services).Installed) {
    Write-Host "Installing Active Directory Domain Services (AD DS)..." -ForegroundColor Yellow
    Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
}

# Create a new AD Forest
Write-Host "Creating a new Active Directory Forest..." -ForegroundColor Cyan

Install-ADDSForest `
    -DomainName $DomainAddress `
    -DomainNetbiosName $NetbiosName `
    -DatabasePath "C:\Windows\NTDS" `
    -LogPath "C:\Windows\NTDS" `
    -SysvolPath "C:\Windows\SYSVOL" `
    -InstallDNS `
    -NoRebootOnCompletion:$false `
    -Force:$true `
    -SafeModeAdministratorPassword (ConvertTo-SecureString "YourSecurePassword123!" -AsPlainText -Force)

Write-Host "Domain $DomainAddress with NetBIOS name $NetbiosName has been created successfully!" -ForegroundColor Green
