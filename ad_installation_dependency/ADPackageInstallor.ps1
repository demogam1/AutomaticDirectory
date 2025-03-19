# PowerShell script to install AD DS and configure a Domain Controller with system requirements

# Variables
$DomainName = "domolia-ad.corp"  # Change to your desired domain name
$StaticIP = "192.168.1.10"  # Set the static IP address for the server
$SubnetMask = "255.255.255.0"  # Set the subnet mask
$Gateway = "192.168.1.1"  # Set the default gateway
$DNSServer = "192.168.1.10"  # Set the DNS server (typically points to this server)

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
    New-NetIPAddress -InterfaceAlias $NetAdapter.Name -IPAddress $StaticIP -PrefixLength (32 - [math]::Log([Convert]::ToInt32($SubnetMask.Split('.').Where{$_ -ne '0'}[0]), 2)) -DefaultGateway $Gateway -Verbose

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

# Update and install required roles and features
Write-Host "Installing Active Directory Domain Services and required features..." -ForegroundColor Yellow
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools -Verbose

# Wait for installation to complete
if ($? -eq $true) {
    Write-Host "AD DS role installed successfully." -ForegroundColor Green
} else {
    Write-Host "Failed to install AD DS role. Exiting script." -ForegroundColor Red
    Exit
}

# Output completion message
Write-Host "Active Directory setup completed successfully for domain: $DomainName" -ForegroundColor Green
