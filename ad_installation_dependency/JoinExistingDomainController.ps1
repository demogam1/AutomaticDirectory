# Etape a suivre 
    # 1-Configurer l'adresse ip en static
    # 2-Add role [Active Directory Domain Service]
    # 3-Promote to domain controler by connecting to domolia-ad.corp with following credentials DOMOLIA-AD\Administrator Toto42sh@
        # with Allow domain controller reinstall with pass toto42sh@
    # 4-Print all server connected to domain controller with Get-ADDomainController -Filter * | Select-Object Name, Domain, Site

param (
    [Parameter(Mandatory = $true)]
    [string]$DomainAddress

)

# Définition des paramètres réseau
$StaticIP = "192.168.1.20"
$SubnetMask = "255.255.255.0"
$Gateway = "192.168.1.1"
$DNSServer = "192.168.1.10"

# Configuration de l'IP statique
Write-Host "🔧 Configuration de l'adresse IP statique..."
$Interface = Get-NetAdapter | Where-Object {$_.Status -eq "Up"}
New-NetIPAddress -InterfaceIndex $Interface.ifIndex -IPAddress $StaticIP -PrefixLength 24 -DefaultGateway $Gateway
Set-DnsClientServerAddress -InterfaceIndex $Interface.ifIndex -ServerAddresses $DNSServer
Write-Host "✅ IP statique configurée: $StaticIP"

# Installation du rôle Active Directory Domain Services
Write-Host "📥 Installation du rôle Active Directory Domain Services..."
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
Write-Host "✅ Rôle AD DS installé avec succès."

# Création des identifiants sécurisés
Write-Host "🔑 Création des identifiants pour la promotion..."
$DomainAdminUser = "DOMOLIA-AD\Administrator"
$DomainAdminPassword = ConvertTo-SecureString "Toto42sh@" -AsPlainText -Force
$DomainCreds = New-Object System.Management.Automation.PSCredential ($DomainAdminUser, $DomainAdminPassword)

$SafeModePassword = ConvertTo-SecureString "toto42sh@" -AsPlainText -Force

# Promotion en tant que contrôleur de domaine
Write-Host "🚀 Promotion du serveur en tant que contrôleur de domaine..."
Install-ADDSDomainController -Credential $DomainCreds -DomainName $DomainAddress -InstallDNS -SafeModeAdministratorPassword $SafeModePassword -Force

Write-Host "✅ Le serveur est maintenant un contrôleur de domaine."

# Affichage des contrôleurs de domaine
Write-Host "📡 Liste des contrôleurs de domaine :"
Get-ADDomainController -Filter * | Select-Object Name, Domain, Site
