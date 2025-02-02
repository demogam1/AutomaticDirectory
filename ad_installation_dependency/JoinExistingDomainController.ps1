param (
    [string]$DomainAddress = Read-Host "Entrez le nom du domaine complet de la forêt existante"
)

# Variables
$StaticIP = "192.168.1.20"  # Adresse IP statique du serveur
$SubnetMask = "255.255.255.0"  # Masque de sous-réseau
$Gateway = "192.168.1.1"  # Passerelle par défaut
$DNSServer = "192.168.1.10"  # Serveur DNS (existant)
$SafeModeAdminPassword = (ConvertTo-SecureString "Toto42sh@" -AsPlainText -Force)  # Mot de passe DSRM

# Vérification des privilèges administrateurs
If (-Not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Veuillez exécuter ce script en tant qu'administrateur." -ForegroundColor Red
    Exit
}

# Fonction pour configurer le réseau
Function Configure-Network {
    Write-Host "Configuration des paramètres réseau..." -ForegroundColor Yellow

    # Récupérer la première carte réseau active
    $NetAdapter = Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | Select-Object -First 1

    if ($NetAdapter -eq $null) {
        Write-Host "Aucune carte réseau active trouvée. Arrêt du script." -ForegroundColor Red
        Exit
    }

    # Configurer l'adresse IP statique
    New-NetIPAddress -InterfaceAlias $NetAdapter.Name `
        -IPAddress $StaticIP `
        -PrefixLength (32 - [math]::Log([Convert]::ToInt32($SubnetMask.Split('.').Where{$_ -ne '0'}[0]), 2)) `
        -DefaultGateway $Gateway -Verbose

    # Configurer le serveur DNS
    Set-DnsClientServerAddress -InterfaceAlias $NetAdapter.Name -ServerAddresses $DNSServer -Verbose

    Write-Host "Configuration réseau terminée." -ForegroundColor Green
}

# Configurer le réseau
Configure-Network

# Installer le rôle AD DS s'il n'est pas encore installé
$Feature = Get-WindowsFeature -Name AD-Domain-Services
if (-not $Feature.Installed) {
    Write-Host "Installation du rôle AD DS..." -ForegroundColor Yellow
    Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
    Write-Host "Installation du rôle AD DS terminée." -ForegroundColor Green
}

# Promouvoir le serveur en tant que contrôleur de domaine de la forêt existante
Write-Host "Promotion du serveur en tant que contrôleur de domaine pour la forêt : $DomainAddress" -ForegroundColor Yellow
Install-ADDSDomainController -DomainName $DomainAddress `
    -SafeModeAdministratorPassword $SafeModeAdminPassword `
    -Force -Verbose

# Vérifier si la promotion a réussi
if ($? -eq $true) {
    Write-Host "Le serveur a été promu avec succès en tant que contrôleur de domaine pour la forêt : $DomainAddress" -ForegroundColor Green
} else {
    Write-Host "Échec de la promotion du serveur en tant que contrôleur de domaine. Veuillez vérifier les erreurs." -ForegroundColor Red
}
