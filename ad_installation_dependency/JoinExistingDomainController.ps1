# PowerShell script to promote a server to a Domain Controller by joining an existing domain
# Includes configuration of static IP and DNS

param (
    [Parameter(Mandatory = $true)]
    [string]$DomainAddress  # Fully Qualified Domain Name of the existing domain (e.g., example.local)
)

# Variables
$StaticIP = "192.168.1.20"  # Set the static IP address for the server
$SubnetMask = "255.255.255.0"  # Set the subnet mask
$Gateway = "192.168.1.1"  # Set the default gateway
$DNSServer = "192.168.1.10"  # Set the DNS server (e.g., the existing Domain Controller)
$SafeModeAdminPassword = (ConvertTo-SecureString "Toto42sh@" -AsPlainText -Force)  # Set a strong DSRM password

# Function to configure network settings
Function Configure-Network {
    Write-Host "Configuring network settings..." -ForegroundColor Yellow

    # Get the first active network adapter
    $NetAdapter = Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | Select-Object -First 1

    if ($NetAdapter -eq $null) {
        Write-Host "No active network adapter found. Exiting script." -ForegroundColor Red
        Exit
    }

    # Set static IP configuration
    New-NetIPAddress -InterfaceAlias $NetAdapter.Name `
        -IPAddress $StaticIP `
        -PrefixLength (32 - [math]::Log([Convert]::ToInt32($SubnetMask.Split('.').Where{$_ -ne '0'}[0]), 2)) `
        -DefaultGateway $Gateway -Verbose

    # Set DNS server
    Set-DnsClientServerAddress -InterfaceAlias $NetAdapter.Name -ServerAddresses $DNSServer -Verbose

    Write-Host "Network configuration completed." -ForegroundColor Green
}

# Ensure script is running as Administrator
If (-Not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Please run this script as Administrator." -ForegroundColor Red
    Exit
}

# Configure the network
Configure-Network

# Check if AD DS role is installed
$Feature = Get-WindowsFeature -Name AD-Domain-Services
if (-not $Feature.Installed) {
    Write-Host "AD DS role is not installed. Please install it before running this script." -ForegroundColor Red
    Exit
}

# Promote the server to a Domain Controller by joining an existing domain
Write-Host "Promoting server to Domain Controller by joining the existing domain: $DomainAddress" -ForegroundColor Yellow
Install-ADDSDomainController -DomainName $DomainAddress `
    -SafeModeAdministratorPassword $SafeModeAdminPassword `
    -Force -Verbose

# Check if promotion was successful
if ($? -eq $true) {
    Write-Host "Server successfully promoted to Domain Controller for the domain: $DomainAddress" -ForegroundColor Green
} else {
    Write-Host "Failed to promote the server to Domain Controller. Please check the error details." -ForegroundColor Red
}
